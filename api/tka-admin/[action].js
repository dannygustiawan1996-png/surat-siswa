// Endpoint admin: /api/tka-admin/<action>  (lihat lib/tka/admin.js)
import { buatRouter } from '../../lib/tka/router.js';
import { adminRoutes } from '../../lib/tka/admin.js';

export default buatRouter(adminRoutes, { adminOnly: true });

// Generate soal AI bisa butuh waktu lebih lama
export const config = { maxDuration: 60 };
