import React, { useState, useEffect, useRef } from 'react';

interface ContextMenuProps {
  selector: string;
}

export default function ContextMenu({ selector }: ContextMenuProps) {
  const [visible, setVisible] = useState(false);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [targetLink, setTargetLink] = useState<{ href: string; text: string } | null>(null);
  const [showToast, setShowToast] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleContext = (e: MouseEvent) => {
      const target = (e.target as HTMLElement).closest(selector) as HTMLAnchorElement;
      if (target) {
        e.preventDefault();
        setTargetLink({ href: target.href, text: target.innerText });
        setPosition({ x: e.pageX, y: e.pageY });
        setVisible(true);
        console.log('Context menu triggered');
      } else {
        setVisible(false);
      }
    };

    const handleClick = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setVisible(false);
      }
    };

    document.addEventListener('contextmenu', handleContext);
    document.addEventListener('click', handleClick);
    return () => {
      document.removeEventListener('contextmenu', handleContext);
      document.removeEventListener('click', handleClick);
    };
  }, [selector]);

  const handleCopy = async () => {
    if (targetLink) {
      const textToCopy = targetLink.href.startsWith('mailto:')
        ? targetLink.href.replace('mailto:', '')
        : targetLink.href;
      await navigator.clipboard.writeText(textToCopy);
      setShowToast(true);
      setVisible(false);
      setTimeout(() => setShowToast(false), 2000);
    }
  };

  const handleOpen = () => {
    if (targetLink) {
      window.open(targetLink.href, '_blank');
      setVisible(false);
    }
  };

  return (
    <>
      {visible && (
        <div
          ref={menuRef}
          id="custom-context-menu"
          style={{
            position: 'absolute',
            top: position.y,
            left: position.x,
            background: 'var(--color-bg)',
            border: '1px solid var(--color-bg-pill)',
            borderRadius: '8px',
            boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
            zIndex: 1000,
            padding: '4px 0',
            minWidth: '160px',
            fontSize: '0.9em',
            color: 'light-dark(black, white)',
          }}
        >
          <div
            onClick={handleOpen}
            style={{
              padding: '8px 16px',
              cursor: 'pointer',
            }}
            className="menu-item"
          >
            {targetLink?.href.startsWith('mailto:') ? 'Enviar Email' : 'Abrir Enlace'}
          </div>
          <div
            onClick={handleCopy}
            style={{
              padding: '8px 16px',
              cursor: 'pointer',
            }}
            className="menu-item"
          >
            Copiar al portapapeles
          </div>
          <style>{`
            .menu-item:hover { background-color: var(--color-bg-pill); }
          `}</style>
        </div>
      )}

      {showToast && (
        <div
          id="copy-toast"
          style={{
            position: 'fixed',
            bottom: '20px',
            left: '50%',
            transform: 'translateX(-50%)',
            background: 'var(--color-bg-pill)',
            color: 'light-dark(black, white)',
            padding: '8px 16px',
            borderRadius: '20px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.2)',
            zIndex: 1001,
            fontSize: '0.85em',
            fontWeight: 500,
            animation: 'fadeInOut 2s forwards',
          }}
        >
          ¡Copiado al portapapeles!
          <style>{`
            @keyframes fadeInOut {
              0% { opacity: 0; transform: translate(-50%, 20px); }
              15% { opacity: 1; transform: translate(-50%, 0); }
              85% { opacity: 1; transform: translate(-50%, 0); }
              100% { opacity: 0; transform: translate(-50%, -20px); }
            }
          `}</style>
        </div>
      )}
    </>
  );
}
