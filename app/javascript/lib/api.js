const API_BASE_URL = '/api/v1';

class ApiClient {
  constructor() {
    this.token = localStorage.getItem('authToken');
  }

  setToken(token) {
    this.token = token;
    if (token) {
      localStorage.setItem('authToken', token);
    } else {
      localStorage.removeItem('authToken');
    }
  }

  getHeaders() {
    const headers = {
      'Content-Type': 'application/json',
    };

    if (this.token) {
      headers['Authorization'] = this.token;
    }

    return headers;
  }

  async request(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`;
    const config = {
      ...options,
      headers: {
        ...this.getHeaders(),
        ...options.headers,
      },
    };

    try {
      const response = await fetch(url, config);

      // Save JWT token from response headers
      const authHeader = response.headers.get('Authorization');
      if (authHeader) {
        this.setToken(authHeader);
      }

      // Handle no content response
      if (response.status === 204) {
        return null;
      }

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Request failed');
      }

      return data;
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  // Auth endpoints
  async login(email, password) {
    return this.request('/users/sign_in', {
      method: 'POST',
      body: JSON.stringify({
        user: { email, password }
      }),
    });
  }

  async signup(email, password, passwordConfirmation, name) {
    return this.request('/users', {
      method: 'POST',
      body: JSON.stringify({
        user: {
          email,
          password,
          password_confirmation: passwordConfirmation,
          name,
        }
      }),
    });
  }

  async logout() {
    try {
      await this.request('/users/sign_out', {
        method: 'DELETE',
      });
    } finally {
      this.setToken(null);
    }
  }

  async getCurrentUser() {
    return this.request('/current_user');
  }

  // Projects endpoints
  async getProjects(page = 1) {
    return this.request(`/projects?page=${page}`);
  }

  async getProject(id) {
    return this.request(`/projects/${id}`);
  }

  async createProject(projectData) {
    return this.request('/projects', {
      method: 'POST',
      body: JSON.stringify({ project: projectData }),
    });
  }

  async updateProject(id, projectData) {
    return this.request(`/projects/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ project: projectData }),
    });
  }

  async deleteProject(id) {
    return this.request(`/projects/${id}`, {
      method: 'DELETE',
    });
  }

  async validateWordPress(id) {
    return this.request(`/projects/${id}/validate_wordpress`, {
      method: 'POST',
    });
  }

  // Plans endpoints
  async getPlans() {
    return this.request('/plans');
  }

  async getPlan(id) {
    return this.request(`/plans/${id}`);
  }

  // Subscriptions endpoints
  async getSubscriptions() {
    return this.request('/subscriptions');
  }

  async createSubscription(planId, paymentMethodId) {
    return this.request('/subscriptions', {
      method: 'POST',
      body: JSON.stringify({
        plan_id: planId,
        payment_method_id: paymentMethodId,
      }),
    });
  }

  async updateSubscription(id, planId) {
    return this.request(`/subscriptions/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ plan_id: planId }),
    });
  }

  async cancelSubscription(id) {
    return this.request(`/subscriptions/${id}`, {
      method: 'DELETE',
    });
  }

  // Articles endpoints
  async getArticles(projectId) {
    return this.request(`/projects/${projectId}/articles`);
  }

  async getArticle(id) {
    return this.request(`/articles/${id}`);
  }

  async createArticle(projectId, articleData) {
    return this.request(`/projects/${projectId}/articles`, {
      method: 'POST',
      body: JSON.stringify({ article: articleData }),
    });
  }

  async updateArticle(id, articleData) {
    return this.request(`/articles/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ article: articleData }),
    });
  }

  async deleteArticle(id) {
    return this.request(`/articles/${id}`, {
      method: 'DELETE',
    });
  }

  async publishArticle(id) {
    return this.request(`/articles/${id}/publish`, {
      method: 'POST',
    });
  }
}

export default new ApiClient();
