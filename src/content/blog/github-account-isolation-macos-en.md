---
title: "Isolating Personal and Work GitHub on macOS"
description: "A step-by-step guide to achieve total, automated isolation of your GitHub accounts (personal and work) on macOS using SSH, Git, and the gh CLI, hardened against supply-chain attacks."
pubDate: 2026-06-06T00:00:00-03:00
tags: ["Security", "Git", "GitHub", "macOS", "DevOps"]
lang: en
postSlug: github-account-isolation-macos
---

When you use the same machine for personal projects and for work, it is only a matter of time before identities start to bleed: a commit signed with the wrong email, a push to the corporate organization from your personal account, or—in the worst case—a credential exposed where it should never have been.

Decided to rebuild my setup from scratch. This is the step-by-step guide to achieve **total, automated isolation** of Git and the GitHub CLI (`gh`) built on a simple premise: physically separate environments by folder and let the tools resolve the correct identity silently.

> "The convenience of a global configuration is the exact same door an attacker uses to move laterally between your accounts."

The goal is not just to avoid silly mistakes, but to shrink the attack surface: a malicious process running in your personal folder **must have no path** to your work repositories, and vice versa.

## Manual or Automated: Pick Your Path

This guide walks you through every file, command, and decision so you understand **exactly** what is happening on your machine. If you prefer to see the mechanics before trusting anything to a script, keep reading.

If you already know how the chain works or just want a quick setup, there is an alternative: an interactive script that does exactly what I describe below. It asks for emails and folders, detects previous configurations, offers to reset them with automatic backups, and executes each step without you having to copy and paste commands.

```bash
curl -sSL https://raw.githubusercontent.com/galiprandi/me/main/scripts/setup-github-isolation.sh | bash
```

> ⚠️  For security, review the content before running it: `curl -sSL ... | cat`.

The manual guide is still the best way to internalize the mechanism; the script is the best way to not forget a single step when switching machines. Choose whichever you prefer.

## 1. Folder Structure

The pillar of this setup is physically separating your repositories. Every piece of automation that follows (Git, SSH, `gh`) relies on *where* the repository lives. Create two clean directories in your Home:

```bash
mkdir -p ~/Repos/Personal
mkdir -p ~/Repos/Work
```

From now on the rule is absolute: personal repos live under `~/Repos/Personal`, work repos under `~/Repos/Work`. The boundary between the two worlds is that path.

## 2. Generating Secure SSH Keys

Do not rely on global HTTPS tokens exposed in environment variables. We will use **ED25519 SSH keys protected by a passphrase**, one per identity. Generate both, entering a strong passphrase when prompted:

```bash
# Personal key
ssh-keygen -t ed25519 -C "personal@mail.com" -f ~/.ssh/id_ed25519_personal

# Work key
ssh-keygen -t ed25519 -C "work@mail.com" -f ~/.ssh/id_ed25519_work
```

Add the keys to the macOS SSH agent (with Keychain integration so you never have to re-type the passphrase):

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
```

Finally, copy the contents of each `.pub` file and add it to the corresponding GitHub account (*Settings → SSH and GPG keys*):

```bash
pbcopy < ~/.ssh/id_ed25519_personal.pub   # paste into your personal account
pbcopy < ~/.ssh/id_ed25519_work.pub       # paste into your work account
```

## 3. Automatic SSH Routing (`~/.ssh/config`)

Both accounts live on the same host (`github.com`), so we need an **alias** that tells SSH which key to use for each identity. The personal account keeps the real host; the work account gets the alias `github.com-work`. Edit or create `~/.ssh/config`:

```ssh-config
# Personal account
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
    AddKeysToAgent yes

# Work account
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
    AddKeysToAgent yes
```

The `IdentitiesOnly yes` directive is critical for security: it forces SSH to use **only** the declared key and prevents it from offering every identity in the agent to the server. Without it, SSH might authenticate with the wrong key and break isolation.

## 4. Smart Git Configuration (`~/.gitconfig`)

Instead of defining a global email (the number-one source of commits signed with the wrong identity), we use the `includeIf` directive so Git applies the correct identity **based on the folder you are standing in**.

**Global config** (`~/.gitconfig`):

```ini
[user]
    name = Your Name

[pull]
    rebase = true

# Apply config depending on directory
[includeIf "gitdir:~/Repos/Personal/"]
    path = ~/.gitconfig-personal

[includeIf "gitdir:~/Repos/Work/"]
    path = ~/.gitconfig-work
```

**Personal config** (`~/.gitconfig-personal`):

```ini
[user]
    email = personal@mail.com
```

**Work config** (`~/.gitconfig-work`):

```ini
[user]
    email = work@mail.com

# Intercepts standard company clones and uses the correct SSH alias
[url "git@github.com-work:"]
    insteadOf = "git@github.com:"
```

**Best practice:** the `insteadOf` rule automates everything else. When you are inside `~/Repos/Work/`, you can run `git clone git@github.com:organization/repo.git` and Git will rewrite the URL to use the `github.com-work` alias, silently picking the work key. You never have to remember which host to use again.

To verify that the identity resolves correctly, stand in each folder and ask Git:

```bash
cd ~/Repos/Work/some-repo && git config user.email   # work@mail.com
cd ~/Repos/Personal/other-repo && git config user.email # personal@mail.com
```

## 5. Full Separation of the GitHub CLI (`gh`)

The GitHub CLI stores credentials **globally** inside `~/.config/gh`, which breaks isolation as soon as you use it in both worlds. The fix is to give `gh` a separate configuration directory per environment via the `GH_CONFIG_DIR` variable, and automate the switch with [`direnv`](https://direnv.net/).

**1. Create separate configuration directories:**

```bash
mkdir -p ~/.config/gh-personal
mkdir -p ~/.config/gh-work
```

**2. Authenticate each environment in isolation** (choose SSH as the protocol in both cases):

```bash
# Authenticate Personal
export GH_CONFIG_DIR=~/.config/gh-personal
gh auth login

# Authenticate Work
export GH_CONFIG_DIR=~/.config/gh-work
gh auth login
```

**3. Install and enable `direnv`:**

```bash
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

**4. Automate the environment switch** with an `.envrc` file per folder:

```bash
# For the Personal folder
echo 'export GH_CONFIG_DIR=~/.config/gh-personal' > ~/Repos/Personal/.envrc
direnv allow ~/Repos/Personal/.envrc

# For the Work folder
echo 'export GH_CONFIG_DIR=~/.config/gh-work' > ~/Repos/Work/.envrc
direnv allow ~/Repos/Work/.envrc
```

From this point on, every time your shell enters one of those folders, `direnv` automatically exports the correct `GH_CONFIG_DIR` and `gh` operates with the intended account. Confirm it with `gh auth status` while standing in each folder.

## 6. Secure Credential Management (Anti-Supply Chain)

This is the section that really matters after an incident. Modern **supply-chain** attacks do not target your password; they target **exfiltration of environment variables and plain-text tokens** that any malicious dependency can read during an `npm install`, a `postinstall`, or a build script. The golden rule is simple: **no credential should ever live in plain text inside an environment variable or a readable file.**

### 6.1. Never use a global `GITHUB_TOKEN`

The most dangerous anti-pattern is defining a helper in your `.gitconfig` that reads a token from a global variable, for example:

```ini
# ❌ DO NOT DO THIS
[credential]
    helper = "!f() { echo \"password=${GITHUB_TOKEN}\"; }; f"
```

If you have this, any process running in your session—including a compromised dependency—can read `$GITHUB_TOKEN` with a simple `echo $GITHUB_TOKEN` and steal access to **all** your repositories. Remove any `export GITHUB_TOKEN=...` from your `.zshrc`, `.bashrc`, or `.env` and revoke any Personal Access Tokens you no longer need from *Settings → Developer settings → Tokens*.

### 6.2. Delegate HTTPS authentication to the `gh` CLI

For cases where you need HTTPS (some pipelines or repos that do not support SSH), do not roll your own helper: delegate to `gh`'s native credential helper. It reads the token from each `GH_CONFIG_DIR`'s secure storage and **never exposes it as an environment variable**. Add this block to your per-environment configs.

In both `~/.gitconfig-personal` and `~/.gitconfig-work`, append:

```ini
[credential "https://github.com"]
    helper =
    helper = !gh auth git-credential
```

> The first line `helper =` (empty) is intentional: it resets any inherited helper from the global configuration before declaring `gh`'s, preventing an insecure helper defined higher up from remaining active.

The magic of isolation is preserved: because `direnv` already changed `GH_CONFIG_DIR` based on the folder, `gh auth git-credential` will deliver the personal token inside `~/Repos/Personal` and the work token inside `~/Repos/Work`, without you touching anything and without the secret ever passing through an environment variable.

### 6.3. Confirm where your tokens actually live

On macOS, `gh` may store the token in a `hosts.yml` file inside its `GH_CONFIG_DIR`. Harden the permissions so only your user can read them, and audit their contents:

```bash
chmod 600 ~/.config/gh-personal/hosts.yml ~/.config/gh-work/hosts.yml
# Verify which account and scopes each environment holds
GH_CONFIG_DIR=~/.config/gh-work gh auth status
```

If you want extra hardening, you can use `gh auth login` with `--with-token` reading from a secrets manager (such as the macOS Keychain or `1Password CLI`) instead of leaving the token on disk, so that not even `hosts.yml` keeps it persistently.

### 6.4. Protect your SSH keys with a passphrase

The SSH keys from step 2 are your last line of defense. An unprotected private key is a file any malware can copy and reuse on another machine. With a strong *passphrase*, even if someone steals `id_ed25519_work`, they cannot use it without decrypting it.

The SSH agent with Keychain integration (step 2) gives you the best of both worlds: you work comfortably without retyping the phrase, but the key **never sits usable in cold storage** on disk. To confirm the agent only has the expected keys loaded:

```bash
ssh-add -l   # should list only your two ed25519 keys
```

### 6.5. Summary of strict rules

- **No global tokens:** avoid exported `GITHUB_TOKEN` and helpers that read plain-text variables.
- **Delegate to native tools:** `gh auth git-credential` resolves HTTPS securely and switches context per folder thanks to `direnv`.
- **Use passphrases:** no SSH key should remain decryptable without a passphrase on disk.
- **Audit permissions:** `chmod 600` on sensitive files and `ssh-add -l` / `gh auth status` as periodic checks.

## Closing: isolation as a habit, not an event

Rebuilding this setup after an incident left me with one certainty: security is not a one-time configuration, but a **boundary that the tools defend for you**. You separate by folder, you let `includeIf`, `insteadOf`, and `direnv` resolve identity, and you remove every place where a secret could live in plain text.

The result is an environment where mixing identities is practically impossible, and where a compromised dependency in your personal world has no path into your work repositories. That is the real convenience: not a global token at your fingertips, but the knowledge that isolation works silently, on its own, every time you change folders.
