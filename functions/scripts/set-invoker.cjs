const path = require('path');
const { GoogleAuth } = require('google-auth-library');

const projectId = 'projekt-pam-city-issues';
const region = 'europe-central2';
const functionName = 'notifyUpvoteOnReport';

async function main() {
  const auth = new GoogleAuth({
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
  });

  const client = await auth.getClient();
  const resource = `projects/${projectId}/locations/${region}/functions/${functionName}`;
  const base = `https://cloudfunctions.googleapis.com/v1/${resource}`;

  const getRes = await client.request({ url: `${base}:getIamPolicy` });
  const policy = getRes.data;

  const hasPublic = policy.bindings?.some(
    (b) =>
      b.role === 'roles/cloudfunctions.invoker' &&
      b.members?.includes('allUsers'),
  );

  if (hasPublic) {
    console.log('IAM OK: allUsers ma roles/cloudfunctions.invoker');
    return;
  }

  if (!policy.bindings) policy.bindings = [];
  policy.bindings.push({
    role: 'roles/cloudfunctions.invoker',
    members: ['allUsers'],
  });

  await client.request({
    url: `${base}:setIamPolicy`,
    method: 'POST',
    data: { policy },
  });

  console.log('IAM ustawione: allUsers → roles/cloudfunctions.invoker');
}

main().catch((e) => {
  console.error('Błąd IAM:', e.response?.data || e.message || e);
  process.exit(1);
});
