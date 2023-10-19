import "graphile-config";
import "postgraphile";
import { PostGraphileAmberPreset } from "postgraphile/presets/amber";
import { PostGraphileRelayPreset } from "postgraphile/presets/relay";
import { PgSimplifyInflectionPreset } from "@graphile/simplify-inflection";
import { makePgService } from "postgraphile/adaptors/pg";
import { PgLazyJWTPreset } from "postgraphile/presets/lazy-jwt";

const isEnvDev = process.env.NODE_ENV === "development";

/** @type {GraphileConfig.Preset} */
export default {
  extends: [
    PostGraphileAmberPreset,
    // PostGraphileRelayPreset,
    PgSimplifyInflectionPreset,
    PgLazyJWTPreset,
  ],
  gather: {
    pgJwtTypes: "public.jwt_token",
  },
  schema: {
    pgJwtSecret: process.env.POSTGRAPHILE_JWT_SECRET,
  },
  pgServices: [
    makePgService({
      connectionString: process.env.POSTGRAPHILE_DB_URL,
      superuserConnectionString: process.env.POSTGRAPILE_DB_SUPERUSER_URL, // for watch mode, only in dev mode...
    }),
  ],
  grafserv: {
    dangerouslyAllowAllCORSRequests: isEnvDev,
    port: process.env.POSTGRAPHILE_PORT,
    watch: isEnvDev,
  },
  disablePlugins: ["NodePlugin"],
  grafast: {
    explain: isEnvDev,
    context: (requestContext, args) => {
      return {
        pgSettings: {
          role: "anon",
          ...args.contextValue.pgSettings,
        },
      };
    },
  },
};
