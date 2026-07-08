-- AlterTable: NICs adicionales (más allá de las MAC WiFi/Ethernet principales).
-- Aditiva y nullable: no toca datos existentes. Formato JSON:
--   [{ "label": "iDRAC", "kind": "eth", "mac": "AA:BB:CC:DD:EE:FF" }, ...]
ALTER TABLE "assets" ADD COLUMN "nics" JSONB;
