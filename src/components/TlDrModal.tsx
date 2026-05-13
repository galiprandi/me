import { useAISummarize, useAI } from '@galiprandi/react-tools';
import { useState, useRef, useEffect } from 'react';

interface TlDrModalProps {
  content: string;
  lang: string;
  buttonLabel?: string;
}

export default function TlDrModal({ content, lang, buttonLabel }: TlDrModalProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [articleContent, setArticleContent] = useState(content);
  const dialogRef = useRef<HTMLDialogElement>(null);
  
  const { isAvailable: isAIAvailable } = useAI({ apis: ['summarizer'] });
  
  const summarize = useAISummarize({
    type: 'tldr',
    format: 'markdown',
    length: 'long',
    outputLanguage: lang === 'es' ? 'es' : 'en',
    streaming: true,
  });

  useEffect(() => {
    // Extract the full article content from the DOM
    const mainElement = document.querySelector('main');
    if (mainElement) {
      // Get the text content, excluding the modal and button
      const clone = mainElement.cloneNode(true) as HTMLElement;
      const modalButton = clone.querySelector('button');
      if (modalButton) modalButton.remove();
      const fullText = clone.textContent || clone.innerText || '';
      if (fullText.length > content.length) {
        setArticleContent(fullText);
      }
    }
  }, []);

  const handleSummarize = async () => {
    setIsOpen(true);
    if (!summarize.data && summarize.status !== 'summarizing') {
      await summarize.summarize(articleContent);
    }
  };

  const handleClose = () => {
    setIsOpen(false);
  };

  useEffect(() => {
    if (isOpen && dialogRef.current) {
      dialogRef.current.showModal();
    } else if (dialogRef.current) {
      dialogRef.current.close();
    }
  }, [isOpen]);

  const defaultButtonLabel = lang === 'es' ? 'Versión TL;DR' : 'TL;DR Version';

  if (!isAIAvailable) {
    return null;
  }

  return (
    <>
      <style>{`
        .tldr-trigger:hover {
          color: light-dark(#000, #fff) !important;
        }
      `}</style>
      <button
        onClick={handleSummarize}
        className="tldr-trigger"
        aria-label={lang === 'es' ? 'Generar resumen del artículo con IA' : 'Generate article summary with AI'}
        style={{
          background: 'transparent',
          color: 'var(--color-texts-light)',
          border: 'none',
          padding: '0',
          cursor: 'pointer',
          fontSize: '0.9em',
          textDecoration: 'none',
          transition: 'color 0.2s ease',
        }}
      >
        {buttonLabel || defaultButtonLabel}
      </button>

      <dialog
        ref={dialogRef}
        onClose={handleClose}
        aria-labelledby="tldr-title"
        style={{
          padding: '2em',
          maxWidth: '600px',
          maxHeight: '80vh',
          overflowY: 'auto',
          borderRadius: '8px',
          border: 'none',
          boxShadow: '0 4px 20px rgba(0,0,0,0.3)',
          position: 'relative',
          backgroundColor: 'var(--color-bg)',
          color: 'inherit',
        }}
      >
        <h2 id="tldr-title" style={{ marginTop: 0 }}>
          {lang === 'es' ? 'Resumen TL;DR' : 'TL;DR Summary'}
        </h2>
        {summarize.status === 'summarizing' && (
          <p style={{ fontStyle: 'italic', color: 'var(--color-texts-light)' }}>
            {lang === 'es' ? 'Generando TL;DR versión con IA...' : 'Generating TL;DR version with AI...'}
          </p>
        )}
        {summarize.status === 'error' && (
          <p style={{ color: 'red' }}>
            {lang === 'es'
              ? 'Error al generar el resumen. Asegúrate de usar un navegador compatible con Chrome AI APIs.'
              : 'Error generating summary. Make sure you use a browser compatible with Chrome AI APIs.'}
          </p>
        )}
        {summarize.data && (
          <div
            style={{
              lineHeight: '1.6',
              whiteSpace: 'pre-wrap',
            }}
            dangerouslySetInnerHTML={{ __html: summarize.data }}
          />
        )}
        <button
          onClick={handleClose}
          aria-label={lang === 'es' ? 'Cerrar resumen' : 'Close summary'}
          style={{
            position: 'absolute',
            top: '1em',
            right: '1em',
            background: 'transparent',
            color: 'var(--color-texts-light)',
            border: 'none',
            fontSize: '1.5em',
            cursor: 'pointer',
            lineHeight: '1',
            padding: '0',
          }}
        >
          ×
        </button>
      </dialog>
    </>
  );
}
