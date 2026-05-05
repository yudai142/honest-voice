import React from 'react';
import ReactDOM from 'react-dom/client';
import RecurringScheduleForm from './components/RecurringScheduleForm';

const App: React.FC = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-500 to-purple-600">
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-4xl font-bold text-white mb-4">Honest Voice</h1>
        <p className="text-xl text-blue-100">
          完全匿名フィードバック収集プラットフォーム
        </p>
      </div>
    </div>
  );
};

const rootElement = document.getElementById('root');
if (rootElement) {
  const root = ReactDOM.createRoot(rootElement);
  root.render(<App />);
}

// 定点観測スケジュール管理ページへのマウント
(window as any).__mountRecurringScheduleForm = (elementId: string) => {
  const el = document.getElementById(elementId);
  if (!el) return;
  const root = ReactDOM.createRoot(el);
  root.render(<RecurringScheduleForm />);
};
