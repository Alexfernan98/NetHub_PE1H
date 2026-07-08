-- AlterTable: specs de hardware para equipos de cómputo (desktop/notebook/server).
ALTER TABLE "assets" ADD COLUMN "cpu" TEXT;
ALTER TABLE "assets" ADD COLUMN "gpu" TEXT;
ALTER TABLE "assets" ADD COLUMN "ram" TEXT;
ALTER TABLE "assets" ADD COLUMN "storage" TEXT;
