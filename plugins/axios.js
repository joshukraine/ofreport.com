export default function ({ $axios }) {
  $axios.defaults.baseURL = process.env.API_URL || 'https://5jojq7ahg5.execute-api.us-east-1.amazonaws.com/prod';
  $axios.defaults.headers.post['Content-Type'] = 'application/json';
}
