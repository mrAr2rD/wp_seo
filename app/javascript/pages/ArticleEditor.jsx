import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import api from '../lib/api';
import { Button } from '../components/ui/button';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/card';

const ArticleEditor = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [article, setArticle] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    content: '',
  });

  useEffect(() => {
    loadArticle();
  }, [id]);

  const loadArticle = async () => {
    try {
      setLoading(true);
      const data = await api.getArticle(id);
      setArticle(data);
      setFormData({
        title: data.title || '',
        content: data.content || '',
      });
    } catch (err) {
      console.error('Failed to load article:', err);
      alert('Failed to load article');
      navigate('/projects');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      await api.updateArticle(id, formData);
      alert('Article saved successfully!');
      await loadArticle();
    } catch (err) {
      alert('Failed to save article: ' + err.message);
    } finally {
      setSaving(false);
    }
  };

  const handlePublish = async () => {
    if (!confirm('Publish this article to WordPress?')) return;

    try {
      await api.publishArticle(id);
      alert('Article queued for publishing!');
      await loadArticle();
    } catch (err) {
      alert('Failed to publish article: ' + err.message);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-12 text-muted-foreground">
        Loading article...
      </div>
    );
  }

  const isReadOnly = article?.status === 'published';

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <Link
            to={`/projects/${article?.project_id}/articles`}
            className="text-sm text-muted-foreground hover:underline mb-2 block"
          >
            ← Back to Articles
          </Link>
          <h1 className="text-3xl font-bold">
            {isReadOnly ? 'View Article' : 'Edit Article'}
          </h1>
          <p className="text-muted-foreground mt-1">
            Status: <span className="font-medium capitalize">{article?.status}</span>
          </p>
        </div>
        <div className="flex gap-2">
          {!isReadOnly && (
            <Button onClick={handleSave} disabled={saving}>
              {saving ? 'Saving...' : 'Save Changes'}
            </Button>
          )}
          {article?.status === 'completed' && (
            <Button onClick={handlePublish} variant="default">
              Publish to WordPress
            </Button>
          )}
        </div>
      </div>

      {/* Editor */}
      <Card>
        <CardHeader>
          <CardTitle>Article Content</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Title */}
          <div className="space-y-2">
            <label htmlFor="title" className="text-sm font-medium">
              Title
            </label>
            <input
              id="title"
              type="text"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              disabled={isReadOnly}
              className="w-full px-3 py-2 border border-input rounded-md bg-background text-lg font-semibold"
            />
          </div>

          {/* Content Editor */}
          <div className="space-y-2">
            <label htmlFor="content" className="text-sm font-medium">
              HTML Content
            </label>
            <textarea
              id="content"
              value={formData.content}
              onChange={(e) => setFormData({ ...formData, content: e.target.value })}
              disabled={isReadOnly}
              rows={20}
              className="w-full px-3 py-2 border border-input rounded-md bg-background font-mono text-sm"
              placeholder="Article HTML content..."
            />
          </div>
        </CardContent>
      </Card>

      {/* Preview */}
      {formData.content && (
        <Card>
          <CardHeader>
            <CardTitle>Preview</CardTitle>
          </CardHeader>
          <CardContent>
            <div
              className="prose max-w-none"
              dangerouslySetInnerHTML={{ __html: formData.content }}
            />
          </CardContent>
        </Card>
      )}
    </div>
  );
};

export default ArticleEditor;
