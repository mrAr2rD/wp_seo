import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import api from '../lib/api';
import { Button } from '../components/ui/button';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../components/ui/card';

const Projects = () => {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadProjects();
  }, []);

  const loadProjects = async () => {
    try {
      setLoading(true);
      const response = await api.getProjects();
      setProjects(Array.isArray(response) ? response : []);
    } catch (err) {
      console.error('Failed to load projects:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id, name) => {
    if (!confirm(`Are you sure you want to delete "${name}"?`)) {
      return;
    }

    try {
      await api.deleteProject(id);
      setProjects(projects.filter(p => p.id !== id));
    } catch (err) {
      console.error('Failed to delete project:', err);
      alert('Failed to delete project');
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Projects</h1>
          <p className="text-muted-foreground mt-1">
            Manage your WordPress sites
          </p>
        </div>
        <Link to="/projects/new">
          <Button>+ New Project</Button>
        </Link>
      </div>

      {/* Projects list */}
      {loading ? (
        <div className="text-center py-12 text-muted-foreground">
          Loading projects...
        </div>
      ) : error ? (
        <div className="text-center py-12">
          <p className="text-destructive mb-4">{error}</p>
          <Button onClick={loadProjects} variant="outline">
            Try Again
          </Button>
        </div>
      ) : projects.length === 0 ? (
        <Card>
          <CardContent className="py-12">
            <div className="text-center">
              <p className="text-muted-foreground mb-4">
                You don't have any projects yet
              </p>
              <Link to="/projects/new">
                <Button>Create Your First Project</Button>
              </Link>
            </div>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4">
          {projects.map((project) => (
            <Card key={project.id}>
              <CardContent className="p-6">
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="text-xl font-semibold">{project.name}</h3>
                      <span
                        className={`text-xs px-2 py-1 rounded ${
                          project.status === 'active'
                            ? 'bg-green-100 text-green-800'
                            : project.status === 'inactive'
                            ? 'bg-gray-100 text-gray-800'
                            : 'bg-yellow-100 text-yellow-800'
                        }`}
                      >
                        {project.status}
                      </span>
                    </div>
                    <p className="text-muted-foreground mb-2">{project.url}</p>
                    <p className="text-sm text-muted-foreground">
                      Created {new Date(project.created_at).toLocaleDateString()}
                    </p>
                  </div>
                  <div className="flex gap-2 ml-4">
                    <Link to={`/projects/${project.id}/articles`}>
                      <Button variant="default" size="sm">
                        Articles
                      </Button>
                    </Link>
                    <Link to={`/projects/${project.id}/edit`}>
                      <Button variant="outline" size="sm">
                        Edit
                      </Button>
                    </Link>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleDelete(project.id, project.name)}
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

export default Projects;
