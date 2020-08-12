const axiosDefaultConfig = ({ $axios }) => {
  $axios.defaults.baseURL =
    process.env.API_URL ||
    'https://v71lxas0sf.execute-api.us-east-1.amazonaws.com/prod';
  $axios.defaults.headers.post['Content-Type'] = 'application/json';
};

export default axiosDefaultConfig;
