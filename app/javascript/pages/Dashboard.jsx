import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import api from '../lib/api';
import { Button } from '../components/ui/button';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../components/ui/card';

const Dashboard = () => {
  const { user } = useAuth();
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

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">
            Welcome back, {user?.attributes?.name || 'User'}!
          </h1>
          <p className="text-muted-foreground mt-1">
            Here's what's happening with your projects
          </p>
        </div>
        <Link to="/projects/new">
          <Button>+ New Project</Button>
        </Link>
      </div>

      {/* Stats */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardDescription>Total Projects</CardDescription>
            <CardTitle className="text-3xl">{projects.length}</CardTitle>
          </CardHeader>
        </Card>

        <Card>
          <CardHeader>
            <CardDescription>Active Projects</CardDescription>
            <CardTitle className="text-3xl">
              {projects.filter(p => p.status === 'active').length}
            </CardTitle>
          </CardHeader>
        </Card>

        <Card>
          <CardHeader>
            <CardDescription>Subscription Status</CardDescription>
            <CardTitle className="text-xl capitalize">
              {user?.attributes?.subscription_status || 'None'}
            </CardTitle>
          </CardHeader>
        </Card>
      </div>

      {/* Recent Projects */}
      <div>
        <h2 className="text-2xl font-bold mb-4">Recent Projects</h2>

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
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {projects.slice(0, 6).map((project) => (
              <Link key={project.id} to={`/projects/${project.id}`}>
                <Card className="hover:shadow-md transition-shadow cursor-pointer">
                  <CardHeader>
                    <CardTitle className="flex items-center justify-between">
                      <span className="truncate">{project.name}</span>
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
                    </CardTitle>
                    <CardDescription className="truncate">
                      {project.url}
                    </CardDescription>
                  </CardHeader>
                </Card>
              </Link>
            ))}
          </div>
        )}
      </div>

      {projects.length > 6 && (
        <div className="text-center">
          <Link to="/projects">
            <Button variant="outline">View All Projects</Button>
          </Link>
        </div>
      )}
    </div>
  );
};

export default Dashboard;
