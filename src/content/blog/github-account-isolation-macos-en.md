---
title: "Multi-Account GitHub Isolation on macOS and Linux"
description: "The definitive guide to isolating N GitHub accounts on a single machine: SSH, Git with commit signing (SSH + GPG), per-folder gh CLI, and supply-chain hardening. Cross-platform macOS and Linux."
pubDate: 2026-06-06T00:00:00-03:00
updatedDate: 2026-07-20T00:00:00-03:00
tags: ["Security", "Git", "GitHub", "macOS", "Linux", "DevOps"]
lang: en
postSlug: github-account-isolation-macos
---

> **Update 2026-07-20:** guide rewritten to support N accounts (not just 2), commit signing with SSH and GPG, `allowed_signers` for verification, primary account as a safe default, cross-platform support (macOS and Linux), and a corrected credentials section (the token lives in Keychain/secret-service, not on disk).

When you use the same machine for several worlds—personal, work, side-projects—it is only a matter of time before identities start to bleed: a commit signed with the wrong email, a push to the corporate organization from your personal account, or—in the worst case—a credential exposed where it should never have been.

I decided to rebuild my setup from scratch. This is the step-by-step guide to achieve **total, automated isolation** of Git and the GitHub CLI (`gh`) built on a simple premise: physically separate environments by folder and let the tools resolve the correct identity silently.

> "The convenience of a global configuration is the exact same door an attacker uses to move laterally between your accounts."

The goal is not just to avoid silly mistakes, but to shrink the attack surface: a malicious process running in your personal folder **must have no path** to your work repositories, and vice versa.

## Prerequisites

This guide works on **macOS** and **Linux** (Debian/Ubuntu). You need:

| Tool | macOS | Linux (Debian/Ubuntu) |
|---|---|---|
| Git | `brew install git` | `sudo apt-get install -y git` |
| GitHub CLI (`gh`) | `brew install gh` | [Official install](https://github.com/cli/cli#installation) (apt repo) |
| OpenSSH | included in macOS | `sudo apt-get install -y openssh-client` |
| GnuPG | `brew install gnupg` | `sudo apt-get install -y gnupg` |
| `direnv` | `brew install direnv` | `sudo apt-get install -y direnv` |
| Clipboard | `pbcopy` (included) | `sudo apt-get install -y xclip` |

> On headless Linux (SSH without GUI), GPG key generation requires `--batch --passphrase ""` to avoid `pinentry-curses`. The companion script handles this automatically.

## Manual or Automated: Pick Your Path

This guide walks you through every file, command, and decision so you understand **exactly** what is happening on your machine. If you prefer to see the mechanics before trusting anything to a script, keep reading.

If you already know how the chain works or just want a quick setup, there is an alternative: an interactive script that does exactly what I describe below. It asks how many accounts you want to configure, emails, folders, and signing keys, detects previous configurations, offers to reset them with automatic backups, and executes each step without you having to copy and paste commands.

```bash
curl -sSL https://raw.githubusercontent.com/galiprandi/me/main/scripts/setup-github-isolation.sh | bash
```

> ⚠️  For security, review the content before running it: `curl -sSL ... | cat`.

The manual guide is still the best way to internalize the mechanism; the script is the best way to not forget a single step when switching machines. Choose whichever you prefer.

## Example convention: 3 accounts

To keep the guide concrete without tying it to a specific case, we will use **3 accounts** as the running example throughout:

| Account | Email | Folder | SSH host | GH_CONFIG_DIR |
|---|---|---|---|---|
| **Work** (primary) | `work@mail.com` | `~/Github/Work` | `github.com` | `~/.config/gh-work` |
| **Personal** | `personal@mail.com` | `~/Github/Personal` | `github.com-personal` | `~/.config/gh-personal` |
| **Side-project** | `side@mail.com` | `~/Github/Side` | `github.com-side` | `~/.config/gh-side` |

The **primary** account (Work) is the one that lives as the real `Host github.com` and as the global default for both git and `gh`. The others are overrides. If your primary is personal, swap the roles. The mechanism is the same for 2, 3, or N accounts: repeat the block for each additional account.

## 1. Folder Structure

The pillar of this setup is physically separating your repositories. Every piece of automation that follows (Git, SSH, `gh`) relies on *where* the repository lives. Create one clean directory per account in your Home:

```bash
mkdir -p ~/Github/Work
mkdir -p ~/Github/Personal
mkdir -p ~/Github/Side
```

From now on the rule is absolute: each account lives under its folder. The boundary between the worlds is that path.

## 2. Generating Secure SSH Keys

Do not rely on global HTTPS tokens exposed in environment variables. We will use **ED25519 SSH keys protected by a passphrase**, one per identity. Generate one per account, entering a strong passphrase when prompted:

```bash
# Work (primary)
ssh-keygen -t ed25519 -C "work@mail.com" -f ~/.ssh/id_ed25519_work

# Personal
ssh-keygen -t ed25519 -C "personal@mail.com" -f ~/.ssh/id_ed25519_personal

# Side-project
ssh-keygen -t ed25519 -C "side@mail.com" -f ~/.ssh/id_ed25519_side
```

Add the keys to the SSH agent (with Keychain integration on macOS so you never have to re-type the passphrase):

```bash
# macOS
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_side

# Linux
ssh-add ~/.ssh/id_ed25519_work
ssh-add ~/.ssh/id_ed25519_personal
ssh-add ~/.ssh/id_ed25519_side
```

Finally, copy the contents of each `.pub` file and add it to the corresponding GitHub account (*Settings → SSH and GPG keys*):

```bash
# macOS
pbcopy < ~/.ssh/id_ed25519_work.pub       # paste into your work account
pbcopy < ~/.ssh/id_ed25519_personal.pub   # paste into your personal account
pbcopy < ~/.ssh/id_ed25519_side.pub       # paste into your side-project account

# Linux (xclip)
xclip -selection clipboard < ~/.ssh/id_ed25519_work.pub
# or: cat ~/.ssh/id_ed25519_work.pub  and copy manually
```

## 3. Automatic SSH Routing (`~/.ssh/config`)

All accounts live on the same host (`github.com`), so we need an **alias** that tells SSH which key to use for each identity. The primary account keeps the real host; the others get aliases. Edit or create `~/.ssh/config`:

```ssh-config
# Primary account (Work)
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
    AddKeysToAgent yes

# Personal account
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
    AddKeysToAgent yes

# Side-project account
Host github.com-side
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_side
    IdentitiesOnly yes
    AddKeysToAgent yes
```

The `IdentitiesOnly yes` directive is critical for security: it forces SSH to use **only** the declared key and prevents it from offering every identity in the agent to the server. Without it, SSH might authenticate with the wrong key and break isolation.

## 4. Smart Git Configuration (`~/.gitconfig`)

Unlike earlier guides that recommended a global without an email, here we define the **primary account as a safe default**: the global has an email, signing enabled, and `allowed_signers` configured. This way, any repo cloned outside the covered folders commits with your primary identity, signed, instead of being left without an identity. The other accounts are overrides via `includeIf`.

**Global config** (`~/.gitconfig`):

```ini
[user]
    name = Your Name
    email = work@mail.com
    signingkey = 2970AAB9B51D85F3   # your GPG key ID (see section 5)

[commit]
    gpgsign = true

[gpg]
    format = openpgp
    program = gpg

[gpg "ssh"]
    allowedSignersFile = ~/.config/git/allowed_signers

# Per-folder overrides
[includeIf "gitdir:~/Github/Personal/"]
    path = ~/.gitconfig-personal

[includeIf "gitdir:~/Github/Side/"]
    path = ~/.gitconfig-side
```

> The primary account (Work) **does not need `includeIf`**: it is already the default. Only secondary accounts are declared as overrides.

**Personal config** (`~/.gitconfig-personal`):

```ini
[user]
    name = Your Name
    email = personal@mail.com
    signingkey = ~/.ssh/id_ed25519_personal.pub

[commit]
    gpgsign = true

[gpg]
    format = ssh

# Intercepts standard clones and uses the correct SSH alias
[url "git@github.com-personal:"]
    insteadOf = "git@github.com:"
```

**Side-project config** (`~/.gitconfig-side`):

```ini
[user]
    name = Your Name
    email = side@mail.com
    signingkey = ~/.ssh/id_ed25519_side.pub

[commit]
    gpgsign = true

[gpg]
    format = ssh

[url "git@github.com-side:"]
    insteadOf = "git@github.com:"
```

**Best practice:** the `insteadOf` rule automates everything else. When you are inside `~/Github/Personal/`, you can run `git clone git@github.com:user/repo.git` and Git will rewrite the URL to use the `github.com-personal` alias, silently picking the personal key. You never have to remember which host to use again.

To verify that the identity resolves correctly, stand in each folder and ask Git:

```bash
cd ~/Github/Work/some-repo     && git config user.email   # work@mail.com
cd ~/Github/Personal/other-repo && git config user.email  # personal@mail.com
cd ~/Github/Side/another-repo  && git config user.email   # side@mail.com
cd /tmp                        && git config user.email   # work@mail.com (default)
```

## 5. Commit Signing (SSH + GPG)

This is the section that sets this guide apart from any other "multi-account GitHub" guide you will find. Signing commits is not decorative: it is the mechanism that proves a commit came from who it claims to come from. Without a signature, an attacker with repo access can inject commits and there is no way to tell them apart from yours. With a signature, `git log --show-signature` tells you in seconds.

Git supports two signing formats: **SSH** (simpler, reuses your ed25519 keys) and **GPG/OpenPGP** (more traditional, requires a separate GPG key). You can mix them: one account with GPG and the others with SSH. In the example, Work uses GPG and Personal/Side use SSH.

### 5.1. SSH signing (recommended to start)

If you already generated your ed25519 keys in step 2, you have everything. You only need to:

1. **Upload the public key to GitHub** as a *signing key* (not just as an SSH key): *Settings → SSH and GPG keys → New SSH key → Key type: Signing Key*. Upload the same `.pub` you loaded before, but marked as signing.

2. **Declare the key in your git profile** (already done in section 4):
   ```ini
   [user]
       signingkey = ~/.ssh/id_ed25519_personal.pub
   [gpg]
       format = ssh
   ```

3. **Configure `allowed_signers`** so git can **verify** SSH signatures (not just create them). Create `~/.config/git/allowed_signers` with one line per email:
   ```
   work@mail.com namespaces="git" ssh-ed25519 AAAAC3... work@mail.com
   personal@mail.com namespaces="git" ssh-ed25519 AAAAC3... personal@mail.com
   side@mail.com namespaces="git" ssh-ed25519 AAAAC3... side@mail.com
   ```
   The format is: `email namespaces="git" <type> <key> <comment>`. The key is the contents of the corresponding `.pub`. And declare it in the global:
   ```ini
   [gpg "ssh"]
       allowedSignersFile = ~/.config/git/allowed_signers
   ```

### 5.2. GPG/OpenPGP signing (for the primary account)

If you want GPG signing for your primary account (more traditional, supported by more tools):

1. **Generate a GPG key** (if you do not have one):
   ```bash
   # macOS (uses pinentry-mac if installed, or native prompt)
   gpg --quick-generate-key "work@mail.com" ed25519 sign 0

   # Headless Linux (SSH without GUI): use --batch to avoid pinentry-curses
   gpg --batch --passphrase "" --quick-generate-key "work@mail.com" ed25519 sign 0
   ```
   List your keys and copy the ID:
   ```bash
   gpg --list-secret-keys --keyid-format=long
   # sec   ed25519/2970AAB9B51D85F3 ...
   ```
   The ID is the part after `/` (e.g.: `2970AAB9B51D85F3`).

2. **Upload the public key to GitHub**: *Settings → SSH and GPG keys → New GPG key*.
   ```bash
   # macOS
   gpg --armor --export 2970AAB9B51D85F3 | pbcopy
   # Linux
   gpg --armor --export 2970AAB9B51D85F3 | xclip -selection clipboard
   ```

3. **Declare in your global** (already done in section 4):
   ```ini
   [user]
       signingkey = 2970AAB9B51D85F3
   [gpg]
       format = openpgp
       program = gpg
   ```

### 5.3. Verification

Confirm that signatures are created and validated correctly:

```bash
# In a personal repo, make a commit and verify the signature
cd ~/Github/Personal/some-repo
git commit --allow-empty -m "test SSH signing"
git log --show-signature -1
# Should say: Good "git" signature for personal@mail.com
# The %G? status should be "G" (good)

# In a work repo
cd ~/Github/Work/some-repo
git commit --allow-empty -m "test GPG signing"
git log --show-signature -1
# Should say: Good signature from work@mail.com
```

If the status is `U` (unknown) or `X` (expired), check that the key is uploaded to GitHub as a signing key and that `allowed_signers` has the correct entry.

## 6. Full Separation of the GitHub CLI (`gh`)

The GitHub CLI stores credentials **globally** inside `~/.config/gh`, which breaks isolation as soon as you use it in several worlds. The fix is to give `gh` a separate configuration directory per environment via the `GH_CONFIG_DIR` variable, and automate the switch with [`direnv`](https://direnv.net/).

**1. Create separate configuration directories:**

```bash
mkdir -p ~/.config/gh-work
mkdir -p ~/.config/gh-personal
mkdir -p ~/.config/gh-side
```

**2. Authenticate each environment in isolation** (choose SSH as the protocol in all cases):

```bash
# Authenticate Work (primary)
export GH_CONFIG_DIR=~/.config/gh-work
gh auth login

# Authenticate Personal
export GH_CONFIG_DIR=~/.config/gh-personal
gh auth login

# Authenticate Side-project
export GH_CONFIG_DIR=~/.config/gh-side
gh auth login
```

**3. Symlink the default to the primary account:**

So that `gh` outside the covered folders uses the primary account (consistent with the git default), create a symlink:

```bash
ln -sfn gh-work ~/.config/gh
```

Now `~/.config/gh` points to `gh-work`. Any `gh` run without `direnv` uses the primary account. Single source of truth: the token lives only once in the Keychain (macOS) or in the system store (Linux via `secret-service`/`pass`).

**4. Install and enable `direnv`:**

```bash
# macOS
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# Linux (Debian/Ubuntu)
sudo apt-get install -y direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc  # or zsh if you use zsh
```

**5. Automate the environment switch** with an `.envrc` file per folder:

```bash
# Work (primary) — no .envrc needed because it is the default via symlink
# Personal
echo 'export GH_CONFIG_DIR=~/.config/gh-personal' > ~/Github/Personal/.envrc
direnv allow ~/Github/Personal/.envrc

# Side-project
echo 'export GH_CONFIG_DIR=~/.config/gh-side' > ~/Github/Side/.envrc
direnv allow ~/Github/Side/.envrc
```

From this point on, every time your shell enters one of those folders, `direnv` automatically exports the correct `GH_CONFIG_DIR` and `gh` operates with the intended account. Confirm it with `gh auth status` while standing in each folder.

```
cd ~/Github/Personal
  ↓
direnv reads .envrc
  ↓
export GH_CONFIG_DIR=~/.config/gh-personal
  ↓
git uses ~/.gitconfig-personal (includeIf)
gh  uses ~/.config/gh-personal
ssh uses github.com-personal (IdentityFile)
```

## 7. Secure Credential Management (Anti-Supply Chain)

This is the section that really matters after an incident. Modern **supply-chain** attacks do not target your password; they target **exfiltration of environment variables and plain-text tokens** that any malicious dependency can read during an `npm install`, a `postinstall`, or a build script. The golden rule is simple: **no credential should ever live in plain text inside an environment variable or a readable file.**

### 7.1. Never use a global `GITHUB_TOKEN`

The most dangerous anti-pattern is defining a helper in your `.gitconfig` that reads a token from a global variable, for example:

```ini
# ❌ DO NOT DO THIS
[credential]
    helper = "!f() { echo \"password=${GITHUB_TOKEN}\"; }; f"
```

If you have this, any process running in your session—including a compromised dependency—can read `$GITHUB_TOKEN` with a simple `echo $GITHUB_TOKEN` and steal access to **all** your repositories. Remove any `export GITHUB_TOKEN=...` from your `.zshrc`, `.bashrc`, or `.env` and revoke any Personal Access Tokens you no longer need from *Settings → Developer settings → Tokens*.

### 7.2. Delegate HTTPS authentication to the `gh` CLI

For cases where you need HTTPS (some pipelines or repos that do not support SSH), do not roll your own helper: delegate to `gh`'s native credential helper. It reads the token from each `GH_CONFIG_DIR`'s secure storage and **never exposes it as an environment variable**. Add this block to your secondary account configs.

In both `~/.gitconfig-personal` and `~/.gitconfig-side`, append:

```ini
[credential "https://github.com"]
    helper =
    helper = !gh auth git-credential
```

> The first line `helper =` (empty) is intentional: it resets any inherited helper from the global configuration before declaring `gh`'s, preventing an insecure helper defined higher up from remaining active.

The magic of isolation is preserved: because `direnv` already changed `GH_CONFIG_DIR` based on the folder, `gh auth git-credential` will deliver the correct account's token without the secret ever passing through an environment variable.

> ⚠️ **Important limitation:** this helper only works if `GH_CONFIG_DIR` is loaded, which depends on `direnv`. In non-interactive contexts—IDEs (VS Code, IntelliJ), GUI git clients (Tower, Fork), cron, local CI hooks—`direnv` does not load and `gh auth git-credential` uses the default (`~/.config/gh` → primary account), delivering the wrong token. That is why this guide recommends **SSH exclusively** for manual interaction: SSH does not depend on `direnv` because the routing lives in `~/.ssh/config` and `~/.gitconfig`, which are read in all contexts. For HTTPS in pipelines, set `GH_CONFIG_DIR` explicitly in the pipeline's environment.

### 7.3. Confirm where your tokens actually live

On modern macOS, `gh` does **not** store the token in `hosts.yml` inside its `GH_CONFIG_DIR`: it stores it in the system **Keychain**. On Linux, `gh` can use `secret-service` (D-Bus), `pass`, or store the token in plain text in `hosts.yml` if no secrets manager is available. The `hosts.yml` file always contains metadata (user, protocol). Verify:

```bash
GH_CONFIG_DIR=~/.config/gh-personal gh auth status
# macOS:  ✓ Logged in to github.com account X (keyring)
# Linux:  ✓ Logged in to github.com account X (keyring)  ← if secret-service/pass is present
#         ✓ Logged in to github.com account X            ← if no manager, token in hosts.yml
```

Token hardening depends on the OS:

**macOS (Keychain):**
- **Do not share the Keychain between accounts:** `gh` stores each token under a distinct name per `GH_CONFIG_DIR`, so they are naturally separated.
- **Audit which tokens exist:** `security find-generic-password -s "gh:github.com" -g 2>&1 | head` (will request Keychain permission).
- **Revoke orphan tokens:** if you stopped using an account, `gh auth logout` inside its `GH_CONFIG_DIR` cleans the Keychain.

**Linux (secret-service / pass / plain text):**
- **Install a secrets manager:** `sudo apt-get install -y gnome-keyring pass` so `gh` uses `secret-service` instead of plain text.
- **If no manager:** the token lives in `hosts.yml`. Make sure to `chmod 600 ~/.config/gh-*/hosts.yml`.
- **Audit:** `cat ~/.config/gh-*/hosts.yml` to see which accounts have tokens.
- **Revoke orphan tokens:** `gh auth logout` inside each `GH_CONFIG_DIR`.

- **`chmod 600` is still useful** for `hosts.yml` and `config.yml` (metadata), but it does not protect the token itself if no secrets manager is present.

If you want extra hardening, you can use `gh auth login` with `--with-token` reading from a secrets manager (such as `1Password CLI`) instead of leaving the token in the Keychain/store, so that not even the system keeps it persistently.

### 7.4. Protect your SSH keys with a passphrase

The SSH keys from step 2 are your last line of defense. An unprotected private key is a file any malware can copy and reuse on another machine. With a strong *passphrase*, even if someone steals `id_ed25519_personal`, they cannot use it without decrypting it.

The SSH agent with Keychain integration (macOS, step 2) or the native agent (Linux) gives you the best of both worlds: you work comfortably without retyping the phrase, but the key **never sits usable in cold storage** on disk. To confirm the agent only has the expected keys loaded:

```bash
ssh-add -l   # should list only your ed25519 keys
```

### 7.5. Summary of strict rules

- **No global tokens:** avoid exported `GITHUB_TOKEN` and helpers that read plain-text variables.
- **Delegate to native tools:** `gh auth git-credential` resolves HTTPS securely and switches context per folder thanks to `direnv` (with the non-interactive context limitation).
- **Prefer SSH over HTTPS:** SSH does not depend on `direnv` and works in IDEs, GUIs, and cron without extra configuration.
- **Sign every commit:** SSH for secondary accounts, GPG for the primary. Configure `allowed_signers` for verification.
- **Use passphrases:** no SSH key should remain usable without decryption on disk.
- **Audit the Keychain/store, not just files:** tokens live there, not in `hosts.yml`.

## Closing: isolation as a habit, not an event

Rebuilding this setup after an incident left me with one certainty: security is not a one-time configuration, but a **boundary that the tools defend for you**. You separate by folder, you let `includeIf`, `insteadOf`, and `direnv` resolve identity, you sign every commit, and you remove every place where a secret could live in plain text.

The result is an environment where mixing identities is practically impossible, where every commit carries a verifiable signature, and where a compromised dependency in your personal world has no path into your work repositories. That is the real convenience: not a global token at your fingertips, but the knowledge that isolation works silently, on its own, every time you change folders.
