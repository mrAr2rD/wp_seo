import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import api from '../lib/api';
import { Button } from '../components/ui/button';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../components/ui/card';

const Articles = () => {
  const { projectId } = useParams();
  const [project, setProject] = useState(null);
  const [articles, setArticles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showNewForm, setShowNewForm] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    gemini_prompt: '',
  });

  useEffect(() => {
    loadData();
  }, [projectId]);

  const loadData = async () => {
    try {
      setLoading(true);
      const [projectData, articlesData] = await Promise.all([
        api.getProject(projectId),
        api.getArticles(projectId),
      ]);
      setProject(projectData);
      setArticles(Array.isArray(articlesData) ? articlesData : []);
    } catch (err) {
      console.error('Failed to load data:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await api.createArticle(projectId, formData);
      setFormData({ title: '', gemini_prompt: '' });
      setShowNewForm(false);
      await loadData();
    } catch (err) {
      alert('Failed to create article: ' + err.message);
    }
  };

  const handlePublish = async (articleId) => {
    if (!confirm('Publish this article to WordPress?')) return;

    try {
      await api.publishArticle(articleId);
      alert('Article queued for publishing!');
      await loadData();
    } catch (err) {
      alert('Failed to publish article: ' + err.message);
    }
  };

  const handleDelete = async (articleId, title) => {
    if (!confirm(`Delete article "${title}"?`)) return;

    try {
      await api.deleteArticle(articleId);
      await loadData();
    } catch (err) {
      alert('Failed to delete article: ' + err.message);
    }
  };

  const getStatusBadge = (status) => {
    const badges = {
      pending: 'bg-gray-100 text-gray-800',
      generating: 'bg-blue-100 text-blue-800',
      completed: 'bg-green-100 text-green-800',
      failed: 'bg-red-100 text-red-800',
      published: 'bg-purple-100 text-purple-800',
    };
    return badges[status] || badges.pending;
  };

  if (loading) {
    return (
      <div className="text-center py-12 text-muted-foreground">
        Loading...
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-destructive mb-4">{error}</p>
        <Button onClick={loadData} variant="outline">
          Try Again
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <Link to="/projects" className="text-sm text-muted-foreground hover:underline mb-2 block">
            ← Back to Projects
          </Link>
          <h1 className="text-3xl font-bold">{project?.name}</h1>
          <p className="text-muted-foreground mt-1">
            AI-generated articles
          </p>
        </div>
        <Button onClick={() => setShowNewForm(!showNewForm)}>
          {showNewForm ? 'Cancel' : '+ New Article'}
        </Button>
      </div>

      {/* New Article Form */}
      {showNewForm && (
        <Card>
          <CardHeader>
            <CardTitle>Generate New Article</CardTitle>
            <CardDescription>
              Provide a title and optional keywords for AI generation
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <label htmlFor="title" className="text-sm font-medium">
                  Article Title
                </label>
                <input
                  id="title"
                  type="text"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  required
                  className="w-full px-3 py-2 border border-input rounded-md bg-background"
                  placeholder="e.g., How to Optimize WordPress Performance"
                />
              </div>

              <div className="space-y-2">
                <label htmlFor="gemini_prompt" className="text-sm font-medium">
                  Keywords (comma-separated)
                </label>
                <input
                  id="gemini_prompt"
                  type="text"
                  value={formData.gemini_prompt}
                  onChange={(e) => setFormData({ ...formData, gemini_prompt: e.target.value })}
                  className="w-full px-3 py-2 border border-input rounded-md bg-background"
                  placeholder="e.g., WordPress, performance, optimization, caching"
                />
              </div>

              <Button type="submit">Generate Article</Button>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Articles List */}
      {articles.length === 0 ? (
        <Card>
          <CardContent className="py-12">
            <div className="text-center text-muted-foreground">
              No articles yet. Create your first AI-generated article!
            </div>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4">
          {articles.map((article) => (
            <Card key={article.id}>
              <CardContent className="p-6">
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="text-xl font-semibold">{article.title}</h3>
                      <span className={`text-xs px-2 py-1 rounded ${getStatusBadge(article.status)}`}>
                        {article.status}
                      </span>
                    </div>
                    {article.gemini_prompt && (
                      <p className="text-sm text-muted-foreground mb-2">
                        Keywords: {article.gemini_prompt}
                      </p>
                    )}
                    {article.published_at && (
                      <p className="text-sm text-muted-foreground">
                        Published: {new Date(article.published_at).toLocaleString()}
                      </p>
                    )}
                  </div>
                  <div className="flex gap-2 ml-4">
                    {article.status === 'completed' && (
                      <>
                        <Link to={`/articles/${article.id}/edit`}>
                          <Button variant="outline" size="sm">
                            Edit
                          </Button>
                        </Link>
                        <Button
                          variant="default"
                          size="sm"
                          onClick={() => handlePublish(article.id)}
                        >
                          Publish
                        </Button>
                      </>
                    )}
                    {article.status === 'published' && (
                      <Link to={`/articles/${article.id}/edit`}>
                        <Button variant="outline" size="sm">
                          View
                        </Button>
                      </Link>
                    )}
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleDelete(article.id, article.title)}
                      className="text-destructive hover:bg-destructive hover:text-destructive-foreground"
                    >
                      Delete
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default Articles;
