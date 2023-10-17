import "graphile-config";
import "postgraphile";
import { PostGraphileAmberPreset } from "postgraphile/presets/amber";
import { PostGraphileRelayPreset } from "postgraphile/presets/relay";

/** @type {GraphileConfig.Preset} */
export default {
  extends: [PostGraphileAmberPreset, PostGraphileRelayPreset],
  gather: {
    pgJwtTypes: "public.jwt_token",
  },
  schema: {
    pgJwtSecret: process.env.POSTGRAPHILE_JWT_SECRET,
  },
};
