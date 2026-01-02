import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import api from '../lib/api';
import { Button } from '../components/ui/button';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../components/ui/card';

const Subscriptions = () => {
  const { user } = useAuth();
  const [plans, setPlans] = useState([]);
  const [subscriptions, setSubscriptions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [plansResponse, subscriptionsResponse] = await Promise.all([
        api.getPlans(),
        api.getSubscriptions(),
      ]);
      setPlans(Array.isArray(plansResponse) ? plansResponse : []);
      setSubscriptions(Array.isArray(subscriptionsResponse) ? subscriptionsResponse : []);
    } catch (err) {
      console.error('Failed to load data:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSubscribe = async (planId) => {
    try {
      // In a real app, you would integrate Stripe Elements here
      // For now, we'll just show an alert
      alert('Stripe integration will be implemented here. Plan ID: ' + planId);
    } catch (err) {
      console.error('Subscription failed:', err);
      alert('Failed to create subscription');
    }
  };

  const handleCancelSubscription = async (subscriptionId) => {
    if (!confirm('Are you sure you want to cancel your subscription?')) {
      return;
    }

    try {
      await api.cancelSubscription(subscriptionId);
      await loadData();
      alert('Subscription cancelled successfully');
    } catch (err) {
      console.error('Failed to cancel subscription:', err);
      alert('Failed to cancel subscription');
    }
  };

  const currentSubscription = subscriptions.find(s => s.status === 'active');

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold">Subscriptions</h1>
        <p className="text-muted-foreground mt-1">
          Manage your subscription plan
        </p>
      </div>

      {/* Current Subscription */}
      {currentSubscription && (
        <Card>
          <CardHeader>
            <CardTitle>Current Subscription</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">
                  Plan: {currentSubscription.plan?.name || 'Unknown'}
                </p>
                <p className="text-sm text-muted-foreground">
                  Status: {currentSubscription.status}
                </p>
              </div>
              <Button
                variant="outline"
                onClick={() => handleCancelSubscription(currentSubscription.id)}
                className="text-destructive"
              >
                Cancel Subscription
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Available Plans */}
      <div>
        <h2 className="text-2xl font-bold mb-4">Available Plans</h2>

        {loading ? (
          <div className="text-center py-12 text-muted-foreground">
            Loading plans...
          </div>
        ) : error ? (
          <div className="text-center py-12">
            <p className="text-destructive mb-4">{error}</p>
            <Button onClick={loadData} variant="outline">
              Try Again
            </Button>
          </div>
        ) : plans.length === 0 ? (
          <Card>
            <CardContent className="py-12">
              <div className="text-center text-muted-foreground">
                No plans available at the moment
              </div>
            </CardContent>
          </Card>
        ) : (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {plans.map((plan) => (
              <Card key={plan.id} className="relative">
                <CardHeader>
                  <CardTitle>{plan.name}</CardTitle>
                  <CardDescription>
                    <span className="text-3xl font-bold">${plan.price}</span>
                    <span className="text-muted-foreground">/month</span>
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <div className="flex items-center gap-2">
                      <span className="text-green-600">✓</span>
                      <span className="text-sm">
                        Up to {plan.max_projects} projects
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-green-600">✓</span>
                      <span className="text-sm">
                        {plan.max_articles} articles per month
                      </span>
                    </div>
                  </div>

                  <Button
                    className="w-full"
                    onClick={() => handleSubscribe(plan.id)}
                    disabled={currentSubscription?.plan_id === plan.id}
                  >
                    {currentSubscription?.plan_id === plan.id
                      ? 'Current Plan'
                      : 'Subscribe'}
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Subscriptions;
