// Endpoint siswa: /api/tka/<action>  (lihat lib/tka/siswa.js)
import { buatRouter } from '../../lib/tka/router.js';
import { siswaRoutes } from '../../lib/tka/siswa.js';

export default buatRouter(siswaRoutes);

// Chat & pembahasan AI butuh waktu beberapa detik
export const config = { maxDuration: 30 };
