const MIN_RETAIN_DAYS = 0;
module.exports = ({ github, context }) => {
  const { owner, repo } = context.repo;
  let retain_days = +process.env.RETAIN_DAYS;
  if (isNaN(retain_days) || retain_days < MIN_RETAIN_DAYS) {
    retain_days = MIN_RETAIN_DAYS;
  }

  console.log(`retain_days = ${retain_days}[${typeof retain_days}]`);
  const notafter = new Date().getTime() - retain_days * 24 * 60 * 60 * 1000;

  console.log('>>>>>> Listing workflow_runs');
  github.rest.actions
    .listWorkflowRunsForRepo({ owner, repo })
    .then(({ data }) => {
      console.log('>>>>>> Listing workflow_runs done.');
      (data.workflow_runs || [])
        .filter(({ status, created_at }) => {
          return status === 'completed' && new Date(created_at).getTime() < notafter;
        })
        .forEach(({ id }) => {
          console.log(`>>>>>> Deleting workflow_runs [${id}]...`);
          github.rest.actions
            .deleteWorkflowRun({ owner, repo, run_id: id })
            .then(() => {
              console.log(`>>>>>> Workflow_runs [${id}] deleted.`);
            })
            .catch(e => {
              console.log(`>>>>>> Get error when deleting workflow_runs [${id}]:`, e);
            });
        });
    })
    .catch(e => {
      console.log('>>>>>> Get error when listing workflow_runs:', e);
    });
};
