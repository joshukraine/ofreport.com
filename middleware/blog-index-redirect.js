const blogIndexRedirect = ({ params, redirect }) => {
  if (parseInt(params.id) === 1) {
    return redirect('/blog/');
  }
  return true;
};

export default blogIndexRedirect;
