export default function ({ $axios }) {
  $axios.defaults.baseURL = process.env.API_URL || 'https://csk7a21fb4.execute-api.us-east-1.amazonaws.com/dev';
  $axios.defaults.headers.post['Content-Type'] = 'application/json';
}
