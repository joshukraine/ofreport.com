const tagIndexRedirect = ({ params, redirect }) => {
  if (parseInt(params.id) === 1) {
    return redirect(`/tags/${params.tag}/`);
  }
  return true;
};

export default tagIndexRedirect;
