import { initializeApp } from 'firebase-admin/app';
import { getDataConnect } from 'firebase-admin/data-connect';
import { getMessaging } from 'firebase-admin/messaging';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';

initializeApp();

setGlobalOptions({ region: 'europe-central2' });

const dataConnect = getDataConnect({
  location: 'europe-central2',
  serviceId: 'projektpam',
});

const notificationContextQuery = `
  query GetUpvoteNotificationContext($reportId: UUID!, $upvoterId: String!) {
    reports(where: { id: { eq: $reportId } }, limit: 1) {
      id
      description
      user {
        id
        fcmToken
      }
      category {
        name
      }
    }
    upvoter: users(where: { id: { eq: $upvoterId } }, limit: 1) {
      username
    }
  }
`;

type NotificationContext = {
  reports: Array<{
    id: string;
    description: string | null;
    user: { id: string; fcmToken: string | null };
    category: { name: string };
  }>;
  upvoter: Array<{ username: string }>;
};

function buildReportSummary(
  categoryName: string,
  description: string | null,
): string {
  const trimmed = description?.trim();
  if (trimmed) {
    return trimmed.length > 80 ? `${trimmed.slice(0, 77)}...` : trimmed;
  }
  return categoryName;
}

export const notifyUpvoteOnReport = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'Musisz być zalogowany, aby wysłać powiadomienie.',
    );
  }

  const reportId = request.data?.reportId;
  if (typeof reportId !== 'string' || reportId.length === 0) {
    throw new HttpsError('invalid-argument', 'Wymagane pole reportId.');
  }

  const upvoterId = request.auth.uid;

  const response = await dataConnect.executeGraphqlRead<
    NotificationContext,
    { reportId: string; upvoterId: string }
  >(notificationContextQuery, {
    variables: { reportId, upvoterId },
  });

  const context = response?.data ?? response;
  const report = context?.reports?.[0];
  if (!report) {
    throw new HttpsError('not-found', 'Nie znaleziono zgłoszenia.');
  }

  const ownerId = report.user.id;
  if (ownerId === upvoterId) {
    return { sent: false, reason: 'self_upvote' };
  }

  const token = report.user.fcmToken?.trim();
  if (!token) {
    return { sent: false, reason: 'no_fcm_token' };
  }

  const upvoterName =
    context?.upvoter?.[0]?.username?.trim() || 'Ktoś';
  const summary = buildReportSummary(
    report.category.name,
    report.description,
  );

  await getMessaging().send({
    token,
    notification: {
      title: 'Nowe wsparcie zgłoszenia',
      body: `${upvoterName} podbił(a) Twoje zgłoszenie: ${summary}`,
    },
    data: {
      type: 'upvote',
      reportId: report.id,
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'report_upvotes',
      },
    },
  });

  return { sent: true };
});
