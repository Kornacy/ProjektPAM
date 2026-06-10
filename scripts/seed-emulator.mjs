import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeApp } from 'firebase-admin/app';
import { getDataConnect } from 'firebase-admin/data-connect';

const projectId = process.env.FIREBASE_PROJECT ?? 'projekt-pam-city-issues';
const dataConnectHost =
  process.env.FIREBASE_DATACONNECT_EMULATOR_HOST ?? '127.0.0.1:9399';
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST ?? '127.0.0.1:9099';

process.env.DATA_CONNECT_EMULATOR_HOST = dataConnectHost;
process.env.FIREBASE_AUTH_EMULATOR_HOST = authHost;

initializeApp({ projectId });

const dataConnect = getDataConnect({
  location: 'europe-central2',
  serviceId: 'projektpam',
});

const categoriesQuery = `
  query GetCategories {
    categories {
      id
    }
  }
`;

function isAlreadySeededError(error) {
  const message = error?.message ?? String(error);
  return (
    message.includes('unique constraint') ||
    message.includes('category_pkey') ||
    message.includes('already exists')
  );
}

async function getCategoryCount() {
  const response = await dataConnect.executeGraphqlRead(categoriesQuery);
  const categories =
    response?.data?.categories ??
    response?.categories ??
    [];

  return categories.length;
}

const seedPath = join(
  dirname(fileURLToPath(import.meta.url)),
  '..',
  'dataconnect',
  'seed.gql',
);
const seedMutation = readFileSync(seedPath, 'utf8');

try {
  const existingCount = await getCategoryCount();
  if (existingCount > 0) {
    console.log(
      `Emulator already has ${existingCount} categories — seed skipped.`,
    );
    process.exit(0);
  }

  const result = await dataConnect.executeGraphql(seedMutation);
  console.log('Emulator seed completed.');
  console.log(JSON.stringify(result, null, 2));
} catch (error) {
  if (isAlreadySeededError(error)) {
    console.log('Categories already exist in emulator — seed skipped.');
    process.exit(0);
  }
  throw error;
}
