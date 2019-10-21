export default function ({ params, redirect }) {
  if (parseInt(params.id) === 1) {
    return redirect(`/tags/${params.tag}/`);
  }
  return true;
}
