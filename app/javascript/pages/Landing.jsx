import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { Button } from '../components/ui/button';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../components/ui/card';

const Landing = () => {
  const navigate = useNavigate();
  const { login, signup, error } = useAuth();
  const [showAuth, setShowAuth] = useState(null); // 'login' or 'signup'
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    passwordConfirmation: '',
    name: '',
  });

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await login(formData.email, formData.password);
      navigate('/dashboard');
    } catch (err) {
      console.error('Login failed:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await signup(formData.email, formData.password, formData.passwordConfirmation, formData.name);
      navigate('/dashboard');
    } catch (err) {
      console.error('Signup failed:', err);
    } finally {
      setLoading(false);
    }
  };

  if (showAuth === 'login') {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background p-4">
        <Card className="w-full max-w-md">
          <CardHeader className="space-y-1">
            <button
              onClick={() => setShowAuth(null)}
              className="text-sm text-muted-foreground hover:underline mb-2 text-left"
            >
              ← Назад на главную
            </button>
            <CardTitle className="text-2xl font-bold text-center">Вход в SEOforge</CardTitle>
            <CardDescription className="text-center">
              Введите свои данные для входа
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleLogin} className="space-y-4">
              <div className="space-y-2">
                <label htmlFor="email" className="text-sm font-medium">
                  Email
                </label>
                <input
                  id="email"
                  name="email"
                  type="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  className="w-full px-3 py-2 border border-input rounded-md bg-background"
                  placeholder="you@example.com"
                />
              </div>

              <div className="space-y-2">
                <label htmlFor="password" className="text-sm font-medium">
                  Пароль
                </label>
                <input
                  id="password"
                  name="password"
                  type="password"
                  value={formData.password}
                  onChange={handleChange}
                  required
                  className="w-full px-3 py-2 border border-input rounded-md bg-background"
                  placeholder="••••••••"
                />
              </div>

              {error && (
                <div className="text-sm text-destructive bg-destructive/10 p-3 rounded-md">
                  {error}
                </div>
              )}

              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? 'Вход...' : 'Войти'}
              </Button>

              <div className="text-center text-sm">
                Нет аккаунта?{' '}
                <button
                  type="button"
                  onClick={() => setShowAuth('signup')}
                  className="text-primary hover:underline"
                >
                  Зарегистрироваться
                </button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (showAuth === 'signup') {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background p-4">
        <Card className="w-full max-w-md">
          <CardHeader className="space-y-1">
            <button
              onClick={() => setShowAuth(null)}
              className="text-sm text-muted-foreground hover:underline mb-2 text-left"
            >
              ← Назад на главную
            </button>
            <CardTitle className="text-2xl font-bold text-center">Регистрация</CardTitle>
            <CardDescription className="text-center">
              Создайте аккаунт для начала работы
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSignup} className="space-y-4">
              <div className="space-y-2">
                <label htmlFor="name" className="text-sm font-medium">
                  Имя
                </label>
                <input
                  id="name"
                  name="name"
                  type="text"
                  value={formData.name}
                  onChange={handleChange}
                  required
                  className="w-full px-3 py-2 border border-input rounded-md bg-background"
                  placeholder="Ваше имя"
                />
              </div>

              <div className="space-y-2">
                <label htmlFor="email" className="text-sm font-medium">
                  Email
                </label>
                <input
                  id="email"
                  name="email"
                  type="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  className="w-full px-3 py-2 border border-input rounded-md bg-background"
                  placeholder="you@example.com"
                />
              </div>

              <div className="space-y-2">
                <label htmlFor="password" className="text-sm font-medium">
                  Пароль
                </label>
                <input
                  id="password"
                  name="password"
                  type="password"
                  value={formData.password}
                  onChange={handleChange}
                  required
                  className="w-full px-3 py-2 border border-input rounded-md bg-background"
                  placeholder="••••••••"
                />
              </div>

              <div className="space-y-2">
                <label htmlFor="passwordConfirmation" className="text-sm font-medium">
                  Подтверждение пароля
                </label>
                <input
                  id="passwordConfirmation"
                  name="passwordConfirmation"
                  type="password"
                  value={formData.passwordConfirmation}
                  onChange={handleChange}
                  required
                  className="w-full px-3 py-2 border border-input rounded-md bg-background"
                  placeholder="••••••••"
                />
              </div>

              {error && (
                <div className="text-sm text-destructive bg-destructive/10 p-3 rounded-md">
                  {error}
                </div>
              )}

              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? 'Создание аккаунта...' : 'Зарегистрироваться'}
              </Button>

              <div className="text-center text-sm">
                Уже есть аккаунт?{' '}
                <button
                  type="button"
                  onClick={() => setShowAuth('login')}
                  className="text-primary hover:underline"
                >
                  Войти
                </button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center text-primary-foreground font-bold">
              CF
            </div>
            <span className="text-xl font-bold">SEOforge</span>
          </div>
          <div className="flex gap-3">
            <Button variant="outline" onClick={() => setShowAuth('login')}>
              Вход
            </Button>
            <Button onClick={() => setShowAuth('signup')}>
              Начать бесплатно
            </Button>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="container mx-auto px-4 py-20 text-center">
        <h1 className="text-5xl md:text-6xl font-bold mb-6">
          Автоматизация создания контента
          <br />
          <span className="text-primary">для вашего WordPress блога</span>
        </h1>
        <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
          SEOforge - это microSaaS платформа для автоматизации создания и оптимизации
          контента с помощью AI. Генерируйте SEO-оптимизированные статьи и публикуйте их
          автоматически.
        </p>
        <div className="flex gap-4 justify-center">
          <Button size="lg" onClick={() => setShowAuth('signup')}>
            Попробовать бесплатно
          </Button>
          <Button size="lg" variant="outline" onClick={() => setShowAuth('login')}>
            Демо
          </Button>
        </div>
      </section>

      {/* Features */}
      <section className="container mx-auto px-4 py-16">
        <h2 className="text-3xl font-bold text-center mb-12">Возможности платформы</h2>
        <div className="grid md:grid-cols-3 gap-8">
          <Card>
            <CardHeader>
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                <span className="text-2xl">🤖</span>
              </div>
              <CardTitle>AI генерация контента</CardTitle>
              <CardDescription>
                Используйте мощь Gemini AI для создания качественных SEO-оптимизированных статей
                по вашим темам и ключевым словам
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                <span className="text-2xl">📝</span>
              </div>
              <CardTitle>Редактор статей</CardTitle>
              <CardDescription>
                Просматривайте и редактируйте сгенерированные статьи перед публикацией с помощью
                встроенного редактора
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                <span className="text-2xl">🚀</span>
              </div>
              <CardTitle>Автопубликация</CardTitle>
              <CardDescription>
                Публикуйте готовые статьи на ваш WordPress сайт в один клик через REST API
                интеграцию
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                <span className="text-2xl">🔍</span>
              </div>
              <CardTitle>SEO оптимизация</CardTitle>
              <CardDescription>
                Автоматическая оптимизация заголовков, мета-тегов и структуры контента для
                лучшего ранжирования
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                <span className="text-2xl">📊</span>
              </div>
              <CardTitle>Управление проектами</CardTitle>
              <CardDescription>
                Подключайте несколько WordPress сайтов и управляйте всем контентом из единого
                интерфейса
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                <span className="text-2xl">💳</span>
              </div>
              <CardTitle>Гибкие тарифы</CardTitle>
              <CardDescription>
                Выбирайте подходящий тариф: от бесплатного для тестирования до Business для
                максимальных возможностей
              </CardDescription>
            </CardHeader>
          </Card>
        </div>
      </section>

      {/* How it works */}
      <section className="container mx-auto px-4 py-16 bg-muted/30 rounded-lg">
        <h2 className="text-3xl font-bold text-center mb-12">Как это работает</h2>
        <div className="max-w-3xl mx-auto space-y-8">
          <div className="flex gap-4">
            <div className="w-12 h-12 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-bold text-xl flex-shrink-0">
              1
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">Подключите WordPress сайт</h3>
              <p className="text-muted-foreground">
                Добавьте свой сайт, указав URL и сгенерировав API-ключ в WordPress
              </p>
            </div>
          </div>

          <div className="flex gap-4">
            <div className="w-12 h-12 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-bold text-xl flex-shrink-0">
              2
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">Создайте тему статьи</h3>
              <p className="text-muted-foreground">
                Укажите тему и ключевые слова для вашей будущей статьи
              </p>
            </div>
          </div>

          <div className="flex gap-4">
            <div className="w-12 h-12 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-bold text-xl flex-shrink-0">
              3
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">AI генерирует контент</h3>
              <p className="text-muted-foreground">
                Искусственный интеллект создаст SEO-оптимизированную статью в HTML формате
              </p>
            </div>
          </div>

          <div className="flex gap-4">
            <div className="w-12 h-12 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-bold text-xl flex-shrink-0">
              4
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">Редактируйте и публикуйте</h3>
              <p className="text-muted-foreground">
                Просмотрите результат, внесите правки при необходимости и опубликуйте в один клик
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section className="container mx-auto px-4 py-16">
        <h2 className="text-3xl font-bold text-center mb-12">Тарифные планы</h2>
        <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
          <Card>
            <CardHeader>
              <CardTitle>Free</CardTitle>
              <div className="mt-4">
                <span className="text-4xl font-bold">$0</span>
                <span className="text-muted-foreground">/месяц</span>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <ul className="space-y-2">
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>1 проект</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>5 статей в месяц</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>Базовый редактор</span>
                </li>
              </ul>
              <Button className="w-full" variant="outline" onClick={() => setShowAuth('signup')}>
                Начать бесплатно
              </Button>
            </CardContent>
          </Card>

          <Card className="border-primary shadow-lg">
            <CardHeader>
              <div className="bg-primary text-primary-foreground text-xs font-semibold px-2 py-1 rounded-full w-fit mb-2">
                Популярный
              </div>
              <CardTitle>Pro</CardTitle>
              <div className="mt-4">
                <span className="text-4xl font-bold">$29</span>
                <span className="text-muted-foreground">/месяц</span>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <ul className="space-y-2">
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>5 проектов</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>50 статей в месяц</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>Расширенный редактор</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>Приоритетная поддержка</span>
                </li>
              </ul>
              <Button className="w-full" onClick={() => setShowAuth('signup')}>
                Выбрать Pro
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Business</CardTitle>
              <div className="mt-4">
                <span className="text-4xl font-bold">$99</span>
                <span className="text-muted-foreground">/месяц</span>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <ul className="space-y-2">
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>Неограниченно проектов</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>200 статей в месяц</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>Все функции Pro</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-600">✓</span>
                  <span>Выделенная поддержка</span>
                </li>
              </ul>
              <Button className="w-full" onClick={() => setShowAuth('signup')}>
                Выбрать Business
              </Button>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* CTA */}
      <section className="container mx-auto px-4 py-20 text-center">
        <h2 className="text-4xl font-bold mb-6">
          Готовы автоматизировать создание контента?
        </h2>
        <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
          Начните использовать SEOforge уже сегодня и увидьте, как AI может трансформировать
          ваш контент-маркетинг
        </p>
        <Button size="lg" onClick={() => setShowAuth('signup')}>
          Начать бесплатно
        </Button>
      </section>

      {/* Footer */}
      <footer className="border-t border-border">
        <div className="container mx-auto px-4 py-8">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4">
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 bg-primary rounded flex items-center justify-center text-primary-foreground text-xs font-bold">
                CF
              </div>
              <span className="font-semibold">SEOforge</span>
            </div>
            <p className="text-sm text-muted-foreground">
              © 2024 SEOforge. Все права защищены.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Landing;
