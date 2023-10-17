import "graphile-config";
import "postgraphile";
import { PostGraphileAmberPreset } from "postgraphile/presets/amber";
import { PostGraphileRelayPreset } from "postgraphile/presets/relay";
import { PgSimplifyInflectionPreset } from "@graphile/simplify-inflection";
import { makePgService } from "postgraphile/adaptors/pg";

const isEnvDev = process.env.NODE_ENV === "development";

/** @type {GraphileConfig.Preset} */
export default {
  extends: [
    PostGraphileAmberPreset,
    PostGraphileRelayPreset,
    PgSimplifyInflectionPreset,
  ],
  gather: {
    pgJwtTypes: "public.jwt_token",
  },
  schema: {
    pgJwtSecret: process.env.POSTGRAPHILE_JWT_SECRET,
  },
  pgServices: [
    makePgService({ connectionString: process.env.POSTGRAPHILE_DB_URL }),
  ],
  grafserv: {
    dangerouslyAllowAllCORSRequests: isEnvDev,
    port: process.env.POSTGRAPHILE_PORT,
    watch: isEnvDev,
  },
  grafast: {
    explain: isEnvDev,
  },
};
