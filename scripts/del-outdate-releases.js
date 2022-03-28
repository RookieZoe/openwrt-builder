const MIN_RETAIN_DAYS = 16;
module.exports = ({ github, context }) => {
  const { owner, repo } = context.repo;
  let retain_days = +process.env.RETAIN_DAYS;
  if (isNaN(retain_days) || retain_days < MIN_RETAIN_DAYS) {
    retain_days = MIN_RETAIN_DAYS;
  }

  console.log(`retain_days = ${retain_days}[${typeof retain_days}]`);
  const notafter = new Date().getTime() - retain_days * 24 * 60 * 60 * 1000;

  console.log('>>>>>> Listing releases');
  github.rest.repos
    .listReleases({ owner, repo })
    .then(({ data }) => {
      console.log('>>>>>> Listing releases done.');
      (data || [])
        .filter(({ published_at }) => {
          return new Date(published_at).getTime() < notafter;
        })
        .forEach(({ id, tag_name }) => {
          console.log(`>>>>>> Deleting release [${id}]...`);
          github.rest.repos
            .deleteRelease({ owner, repo, release_id: id })
            .then(() => {
              console.log(`>>>>>> Release [${id}] deleted.`);
              console.log(`>>>>>> Deleting tag [${tag_name}]...`);
              github.rest.git
                .deleteRef({
                  owner,
                  repo,
                  ref: `tags/${tag_name}`,
                })
                .then(() => {
                  console.log(`>>>>>> Tag [${tag_name}] deleted.`);
                })
                .catch(e => {
                  console.log(`>>>>>> Get error when deleting tag [${tag_name}]:`, e);
                });
            })
            .catch(e => {
              console.log(`>>>>>> Get error when deleting release [${id}]:`, e);
            });
        });
    })
    .catch(e => {
      console.log('>>>>>> Get error when listing releases:', e);
    });
};
