--
-- PostgreSQL database dump
--

\restrict 0RI5kmozo6A5oGOSpNJKsHkJcc5JaZC2NHWdolXeA9SduABR0uMnNrZAMSvedES

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6 (Ubuntu 17.6-1build1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS "users_tenantId_fkey";
ALTER TABLE IF EXISTS ONLY public.suppliers DROP CONSTRAINT IF EXISTS "suppliers_tenantId_fkey";
ALTER TABLE IF EXISTS ONLY public.sales DROP CONSTRAINT IF EXISTS "sales_tenantId_fkey";
ALTER TABLE IF EXISTS ONLY public.sales DROP CONSTRAINT IF EXISTS "sales_employeeId_fkey";
ALTER TABLE IF EXISTS ONLY public.sale_items DROP CONSTRAINT IF EXISTS "sale_items_saleId_fkey";
ALTER TABLE IF EXISTS ONLY public.sale_items DROP CONSTRAINT IF EXISTS "sale_items_inventoryId_fkey";
ALTER TABLE IF EXISTS ONLY public.restock_receipts DROP CONSTRAINT IF EXISTS "restock_receipts_tenantId_fkey";
ALTER TABLE IF EXISTS ONLY public.restock_receipts DROP CONSTRAINT IF EXISTS "restock_receipts_supplierId_fkey";
ALTER TABLE IF EXISTS ONLY public.refresh_tokens DROP CONSTRAINT IF EXISTS "refresh_tokens_userId_fkey";
ALTER TABLE IF EXISTS ONLY public.push_subscriptions DROP CONSTRAINT IF EXISTS "push_subscriptions_userId_fkey";
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS "products_tenantId_fkey";
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS "products_categoryId_fkey";
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS "products_brandId_fkey";
ALTER TABLE IF EXISTS ONLY public.product_variants DROP CONSTRAINT IF EXISTS "product_variants_tenantId_fkey";
ALTER TABLE IF EXISTS ONLY public.product_variants DROP CONSTRAINT IF EXISTS "product_variants_productId_fkey";
ALTER TABLE IF EXISTS ONLY public.inventory_items DROP CONSTRAINT IF EXISTS "inventory_items_variantId_fkey";
ALTER TABLE IF EXISTS ONLY public.inventory_items DROP CONSTRAINT IF EXISTS "inventory_items_tenantId_fkey";
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS "categories_tenantId_fkey";
ALTER TABLE IF EXISTS ONLY public.brands DROP CONSTRAINT IF EXISTS "brands_tenantId_fkey";
DROP INDEX IF EXISTS public."users_tenantId_idx";
DROP INDEX IF EXISTS public.users_email_key;
DROP INDEX IF EXISTS public.users_email_idx;
DROP INDEX IF EXISTS public.tenants_status_idx;
DROP INDEX IF EXISTS public."tenants_registrationNumber_key";
DROP INDEX IF EXISTS public."suppliers_tenantId_idx";
DROP INDEX IF EXISTS public."sales_tenantId_idx";
DROP INDEX IF EXISTS public."sales_saleTime_idx";
DROP INDEX IF EXISTS public."sales_receiptNumber_key";
DROP INDEX IF EXISTS public."sales_receiptNumber_idx";
DROP INDEX IF EXISTS public."sale_items_saleId_idx";
DROP INDEX IF EXISTS public."sale_items_inventoryId_idx";
DROP INDEX IF EXISTS public."restock_receipts_tenantId_idx";
DROP INDEX IF EXISTS public."restock_receipts_receiptNumber_idx";
DROP INDEX IF EXISTS public."refresh_tokens_userId_idx";
DROP INDEX IF EXISTS public.refresh_tokens_token_key;
DROP INDEX IF EXISTS public.refresh_tokens_token_idx;
DROP INDEX IF EXISTS public."push_subscriptions_userId_idx";
DROP INDEX IF EXISTS public.push_subscriptions_endpoint_key;
DROP INDEX IF EXISTS public."products_tenantId_idx";
DROP INDEX IF EXISTS public."products_productType_idx";
DROP INDEX IF EXISTS public.products_name_idx;
DROP INDEX IF EXISTS public."products_categoryId_idx";
DROP INDEX IF EXISTS public."products_brandId_idx";
DROP INDEX IF EXISTS public."product_variants_tenantId_idx";
DROP INDEX IF EXISTS public."product_variants_sku_tenantId_key";
DROP INDEX IF EXISTS public."product_variants_productId_idx";
DROP INDEX IF EXISTS public."inventory_items_variantId_idx";
DROP INDEX IF EXISTS public."inventory_items_tenantId_idx";
DROP INDEX IF EXISTS public.inventory_items_quantity_idx;
DROP INDEX IF EXISTS public."inventory_items_expiryDate_idx";
DROP INDEX IF EXISTS public."categories_tenantId_idx";
DROP INDEX IF EXISTS public."categories_name_tenantId_key";
DROP INDEX IF EXISTS public."brands_tenantId_idx";
DROP INDEX IF EXISTS public."brands_name_tenantId_key";
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.tenants DROP CONSTRAINT IF EXISTS tenants_pkey;
ALTER TABLE IF EXISTS ONLY public.suppliers DROP CONSTRAINT IF EXISTS suppliers_pkey;
ALTER TABLE IF EXISTS ONLY public.sales DROP CONSTRAINT IF EXISTS sales_pkey;
ALTER TABLE IF EXISTS ONLY public.sale_items DROP CONSTRAINT IF EXISTS sale_items_pkey;
ALTER TABLE IF EXISTS ONLY public.restock_receipts DROP CONSTRAINT IF EXISTS restock_receipts_pkey;
ALTER TABLE IF EXISTS ONLY public.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.push_subscriptions DROP CONSTRAINT IF EXISTS push_subscriptions_pkey;
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS products_pkey;
ALTER TABLE IF EXISTS ONLY public.product_variants DROP CONSTRAINT IF EXISTS product_variants_pkey;
ALTER TABLE IF EXISTS ONLY public.inventory_items DROP CONSTRAINT IF EXISTS inventory_items_pkey;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS categories_pkey;
ALTER TABLE IF EXISTS ONLY public.brands DROP CONSTRAINT IF EXISTS brands_pkey;
ALTER TABLE IF EXISTS ONLY public._prisma_migrations DROP CONSTRAINT IF EXISTS _prisma_migrations_pkey;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.tenants;
DROP TABLE IF EXISTS public.suppliers;
DROP TABLE IF EXISTS public.sales;
DROP TABLE IF EXISTS public.sale_items;
DROP TABLE IF EXISTS public.restock_receipts;
DROP TABLE IF EXISTS public.refresh_tokens;
DROP TABLE IF EXISTS public.push_subscriptions;
DROP TABLE IF EXISTS public.products;
DROP TABLE IF EXISTS public.product_variants;
DROP TABLE IF EXISTS public.inventory_items;
DROP TABLE IF EXISTS public.categories;
DROP TABLE IF EXISTS public.brands;
DROP TABLE IF EXISTS public._prisma_migrations;
DROP TYPE IF EXISTS public."UserRole";
DROP TYPE IF EXISTS public."TenantStatus";
DROP TYPE IF EXISTS public."SaleType";
DROP TYPE IF EXISTS public."ProductType";
DROP TYPE IF EXISTS public."PaymentMethod";
DROP TYPE IF EXISTS public."DiscountType";
DROP EXTENSION IF EXISTS google_vacuum_mgmt;
-- *not* dropping schema, since initdb creates it
DROP SCHEMA IF EXISTS google_vacuum_mgmt;
--
-- Name: google_vacuum_mgmt; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA google_vacuum_mgmt;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: google_vacuum_mgmt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS google_vacuum_mgmt WITH SCHEMA google_vacuum_mgmt;


--
-- Name: EXTENSION google_vacuum_mgmt; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION google_vacuum_mgmt IS 'extension for assistive operational tooling';


--
-- Name: DiscountType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."DiscountType" AS ENUM (
    'PERCENTAGE',
    'FIXED'
);


--
-- Name: PaymentMethod; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PaymentMethod" AS ENUM (
    'CASH',
    'CARD',
    'MOBILE_PAYMENT',
    'OTHER'
);


--
-- Name: ProductType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ProductType" AS ENUM (
    'GENERAL',
    'MEDICINE'
);


--
-- Name: SaleType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SaleType" AS ENUM (
    'POS',
    'ONLINE',
    'WHOLESALE'
);


--
-- Name: TenantStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TenantStatus" AS ENUM (
    'ACTIVE',
    'SUSPENDED',
    'INACTIVE'
);


--
-- Name: UserRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."UserRole" AS ENUM (
    'SUPER_ADMIN',
    'OWNER',
    'EMPLOYEE'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: brands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brands (
    id text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "tenantId" text NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "tenantId" text NOT NULL
);


--
-- Name: inventory_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_items (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "variantId" text,
    "itemName" text,
    quantity integer DEFAULT 0 NOT NULL,
    "purchasePrice" double precision NOT NULL,
    "retailPrice" double precision NOT NULL,
    "maxDiscountRate" double precision DEFAULT 0 NOT NULL,
    "expiryDate" timestamp(3) without time zone,
    "mfgDate" timestamp(3) without time zone,
    "batchNo" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variants (
    id text NOT NULL,
    "productId" text NOT NULL,
    "variantName" text NOT NULL,
    sku text NOT NULL,
    "retailPrice" double precision NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "tenantId" text NOT NULL
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "brandId" text,
    "categoryId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "genericName" text,
    "manufacturerName" text,
    "productType" public."ProductType" DEFAULT 'GENERAL'::public."ProductType" NOT NULL,
    "tenantId" text NOT NULL
);


--
-- Name: push_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_subscriptions (
    id text NOT NULL,
    "userId" text NOT NULL,
    endpoint text NOT NULL,
    keys jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id text NOT NULL,
    token text NOT NULL,
    "userId" text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: restock_receipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restock_receipts (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "receiptNumber" text NOT NULL,
    "supplierId" text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: sale_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sale_items (
    id text NOT NULL,
    "saleId" text NOT NULL,
    "inventoryId" text NOT NULL,
    quantity integer NOT NULL,
    "unitPrice" double precision NOT NULL,
    subtotal double precision NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: sales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "employeeId" text NOT NULL,
    "receiptNumber" text NOT NULL,
    "saleTime" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "totalAmount" double precision NOT NULL,
    "totalProfit" double precision NOT NULL,
    "customerName" text,
    "customerPhone" text,
    "saleType" public."SaleType" DEFAULT 'POS'::public."SaleType" NOT NULL,
    "paymentMethod" public."PaymentMethod" DEFAULT 'CASH'::public."PaymentMethod" NOT NULL,
    "discountType" public."DiscountType",
    "discountValue" double precision DEFAULT 0,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suppliers (
    id text NOT NULL,
    name text NOT NULL,
    "contactPerson" text,
    phone text,
    email text,
    address text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "tenantId" text NOT NULL
);


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id text NOT NULL,
    name text NOT NULL,
    "registrationNumber" text,
    "addressStreet" text,
    "addressCity" text,
    "addressZone" text,
    latitude double precision,
    longitude double precision,
    status public."TenantStatus" DEFAULT 'ACTIVE'::public."TenantStatus" NOT NULL,
    preferences jsonb,
    theme jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    "fullName" text NOT NULL,
    phone text,
    role public."UserRole" DEFAULT 'EMPLOYEE'::public."UserRole" NOT NULL,
    "tenantId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public._prisma_migrations VALUES ('78ea570b-f1c1-4b7d-b77f-3b2d6e01dd19', '8c50a83f713e04af13c44e67cd852e3b2e1bf27ff0c90ab94800c76db49ce249', '2025-11-21 12:20:37.674355+00', '20251115161517_init', NULL, NULL, '2025-11-21 12:20:37.386756+00', 1);
INSERT INTO public._prisma_migrations VALUES ('ca775b6a-75db-4cab-bebe-58ad09ec3dd4', '56eb7f411017c3793f2abca21a0bb76e839567988b362211c4ea9b16bd52978c', '2025-11-21 12:20:38.041045+00', '20251120063136_add_product_medicine_fields', NULL, NULL, '2025-11-21 12:20:37.781857+00', 1);
INSERT INTO public._prisma_migrations VALUES ('5f96ef87-741b-4f26-a720-76a074e4f2c4', '6984e70ea099b0a0cdb1e619db5e7b731e50e1394b53f63832b7e4c3eabd53e1', '2025-11-21 12:20:38.424142+00', '20251120070840_add_push_subscriptions', NULL, NULL, '2025-11-21 12:20:38.144106+00', 1);
INSERT INTO public._prisma_migrations VALUES ('fc72fb36-73e1-40b6-bd76-7cb57b24b2c0', 'bc7d796b1e8ed04f7f394125ffbad4df36be8a2c789522b7c0274b7b6917e2af', '2025-11-21 12:20:38.851173+00', '20251121121742_add_tenant_id_to_brands', NULL, NULL, '2025-11-21 12:20:38.567197+00', 1);
INSERT INTO public._prisma_migrations VALUES ('dbacd927-0676-4b7a-b3f2-9b72e2681a80', 'ae759ff783b9ecf0c8cf5f047b64e9106eefb668d6b7de4edf277aafd303f6da', '2025-11-21 12:22:36.515714+00', '20251121122205_add_tenant_id_to_categories_suppliers_products_variants', NULL, NULL, '2025-11-21 12:22:36.236143+00', 1);


--
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: inventory_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.inventory_items VALUES ('bab12e87-06cc-4941-baf2-3e0d856ac528', '2e0136a8-d74a-408d-b8b6-7656732387d4', '36e5b2dc-af9a-417a-9bda-da5010f49d1c', 'baby lotion', 10, 8, 10, 0, NULL, NULL, 'BATCH-1763729433175', '2025-11-21 12:50:33.194', '2025-11-21 12:50:33.194');
INSERT INTO public.inventory_items VALUES ('a18396b7-95f2-4f05-9ea7-53dc87afd83c', '2e0136a8-d74a-408d-b8b6-7656732387d4', '36e5b2dc-af9a-417a-9bda-da5010f49d1c', 'baby lotion - Standard', 2, 8, 10, 0, NULL, NULL, 'BATCH-1763730130229', '2025-11-21 13:02:10.333', '2025-11-21 13:02:10.333');
INSERT INTO public.inventory_items VALUES ('6d3f9e0c-c8e6-4712-855d-7c7ccbbcb3dd', '2e0136a8-d74a-408d-b8b6-7656732387d4', '36e5b2dc-af9a-417a-9bda-da5010f49d1c', 'baby lotion - Standard', 1, 8, 10, 0, NULL, NULL, 'BATCH-1763730452889', '2025-11-21 13:07:32.997', '2025-11-21 13:07:32.997');
INSERT INTO public.inventory_items VALUES ('1a888398-f397-43ea-b358-e81c53ecde3f', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'e89238d7-f574-433b-ba11-337f5ccb1858', 'Tetrasol', 6, 115, 125, 0, NULL, NULL, 'BATCH-1763739183468', '2025-11-21 15:33:03.481', '2025-11-22 06:42:01.632');
INSERT INTO public.inventory_items VALUES ('ba94bc08-1b99-4f7c-92ac-6e636bc794db', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd98cfb38-2288-4231-a690-e3e70b9529c2', 'Linatab E 5/10 Tab', 30, 25.83, 30, 0, NULL, NULL, 'BATCH-1763739900157', '2025-11-21 15:45:00.175', '2025-11-21 15:45:00.175');
INSERT INTO public.inventory_items VALUES ('a2c2a4a1-8481-4d51-b3ad-145409d6fac8', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '5c626750-ddc6-4cff-a775-6fd8d6423c71', 'Camlosart 5/20  Tab', 30, 10.56, 12, 0, NULL, NULL, 'BATCH-1763739935340', '2025-11-21 15:45:35.35', '2025-11-21 15:45:35.35');
INSERT INTO public.inventory_items VALUES ('edd40cae-51b1-4a14-abfa-f97cd2258c97', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '08fb75e7-b5e2-4888-891a-c276a7e85bdc', 'Rivo 0.5mg', 8, 7.04, 8, 0, NULL, NULL, 'BATCH-1763739996997', '2025-11-21 15:46:37.011', '2025-11-21 15:46:37.011');
INSERT INTO public.inventory_items VALUES ('a8a11438-706f-4066-8d4d-a69563a82878', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '41206c77-cc3b-4f28-908e-e42605153cdf', 'Lopirel 75mg Tab', 30, 10.22, 12, 0, NULL, NULL, 'BATCH-1763740019768', '2025-11-21 15:46:59.778', '2025-11-21 15:46:59.778');
INSERT INTO public.inventory_items VALUES ('18acace4-61ea-4fa0-b723-5d1edc4f4f1c', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '30de1cd6-b5c0-428b-93dc-9ccaeaf28702', 'Larcadip 10mg Tab', 60, 4.4, 5, 0, NULL, NULL, 'BATCH-1763740036349', '2025-11-21 15:47:16.359', '2025-11-21 15:47:16.359');
INSERT INTO public.inventory_items VALUES ('7e87e3b8-f87c-4e66-bded-fa853b012990', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'b137143b-250c-42e6-bc7c-7114a8bd7a51', 'Emayid 10mg Tab', 30, 21.16, 25, 0, NULL, NULL, 'BATCH-1763740054729', '2025-11-21 15:47:34.74', '2025-11-21 15:47:34.74');
INSERT INTO public.inventory_items VALUES ('c0bc89e6-6445-4deb-a653-c5fcf4a3846d', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3040af8b-c379-4b9a-a9ab-df8c72c06012', 'Rostil 135mg Tab', 60, 6.16, 7, 0, NULL, NULL, 'BATCH-1763740071738', '2025-11-21 15:47:51.748', '2025-11-21 15:47:51.748');
INSERT INTO public.inventory_items VALUES ('2af78122-c767-4d36-89f2-3d7f7029e4f3', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'fcc0f89e-1587-4a20-a760-b5e25f9723a7', 'Rolip 5mg Tab', 30, 10.16, 12, 0, NULL, NULL, 'BATCH-1763740106556', '2025-11-21 15:48:26.567', '2025-11-21 15:48:26.567');
INSERT INTO public.inventory_items VALUES ('c98acaa8-6757-4056-b15e-acb28737be3f', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'b506472d-de6a-40b0-ba03-c3c4f3f75f1d', 'Tenocab 50mg', 50, 7, 8, 0, NULL, NULL, 'BATCH-1763740126911', '2025-11-21 15:48:46.921', '2025-11-21 15:48:46.921');
INSERT INTO public.inventory_items VALUES ('9d803485-ec4a-402e-811e-c6f82249a1da', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd4e89b60-7af4-4428-9e84-119affa90155', 'Angilock Plus 12.5mg Tab', 50, 4.5, 10, 0, NULL, NULL, 'BATCH-1763740177008', '2025-11-21 15:49:37.024', '2025-11-21 15:49:37.024');
INSERT INTO public.inventory_items VALUES ('592773dc-7933-4cb2-a5d6-d5ab5c6fd296', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'a666d35e-f9cb-4771-995c-e9758bb6f159', 'Tenoloc 50mg Tab', 100, 0.68, 1, 0, NULL, NULL, 'BATCH-1763740336796', '2025-11-21 15:52:16.809', '2025-11-21 15:52:16.809');
INSERT INTO public.inventory_items VALUES ('9b6408ae-91cb-46da-9476-b0eadd049bdc', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd9fe6350-d7d0-4d92-9908-9756cbcd4eff', 'Sabitar 50mg Tab', 30, 39, 45, 0, NULL, NULL, 'BATCH-1763740407028', '2025-11-21 15:53:27.037', '2025-11-21 15:53:27.037');
INSERT INTO public.inventory_items VALUES ('10a0b43e-1eaf-4a33-b43a-7eabbd102605', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'cfe05d2e-ab78-4690-ab6d-249ab7e7418e', 'Osartil 50mg Tab', 38, 8.6, 10, 0, NULL, NULL, 'BATCH-1763740465728', '2025-11-21 15:54:25.738', '2025-11-21 15:54:25.738');
INSERT INTO public.inventory_items VALUES ('078ac775-f12b-413d-aeb3-f8777e0c3eb8', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '4c3ff77f-598d-4a72-aa69-34942e4163f2', 'Osartil 50 Plus', 50, 8.6, 10, 0, NULL, NULL, 'BATCH-1763740509269', '2025-11-21 15:55:09.283', '2025-11-21 15:55:09.283');
INSERT INTO public.inventory_items VALUES ('7dc545c0-adb4-41f5-a575-53608af4eb84', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '4b08316f-d0f5-4bbf-9def-a615bd3c98b5', 'Amdocal Plus 50mg', 40, 6, 8.5, 0, NULL, NULL, 'BATCH-1763740653531', '2025-11-21 15:57:33.543', '2025-11-21 15:57:33.543');
INSERT INTO public.inventory_items VALUES ('4409a7bd-ed71-4a12-9f89-784742955269', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '975df487-0dd5-419d-a9c6-203e69dd2828', 'Frulac-20 Tab', 50, 7.92, 9, 0, NULL, NULL, 'BATCH-1763740731483', '2025-11-21 15:58:51.494', '2025-11-21 15:58:51.494');
INSERT INTO public.inventory_items VALUES ('ce7038d0-e282-4a06-9dd9-4b013218cd41', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'b40ad9d9-fa3b-4920-aad5-2a1e75ab4d7e', 'Lasix 40mg Tab', 200, 1.32, 1.5, 0, NULL, NULL, 'BATCH-1763740770692', '2025-11-21 15:59:30.702', '2025-11-21 15:59:30.702');
INSERT INTO public.inventory_items VALUES ('b4303c34-db23-4588-8ceb-6764f080f6a3', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '9b6ed086-28c4-4776-8d9f-3628194dedd1', 'Zolium 0.5mg Tab', 100, 3.03, 3.5, 0, NULL, NULL, 'BATCH-1763740803787', '2025-11-21 16:00:03.798', '2025-11-21 16:00:03.798');
INSERT INTO public.inventory_items VALUES ('3c92bdad-5273-49ec-8d59-1d09ed0ea832', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '7b34838f-f75f-4c44-850a-06f1b5130ccb', 'Disopan 0.5mg Tab', 100, 6.9, 8, 0, NULL, NULL, 'BATCH-1763740852086', '2025-11-21 16:00:52.101', '2025-11-21 16:00:52.101');
INSERT INTO public.inventory_items VALUES ('05ace7d3-4aa6-4a00-908e-27f8ff3be476', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '51985e6d-ef5c-4de4-950b-791c5f264377', 'Disopan 2mg Tab', 50, 10.9, 12.5, 0, NULL, NULL, 'BATCH-1763740882877', '2025-11-21 16:01:22.901', '2025-11-21 16:01:22.901');
INSERT INTO public.inventory_items VALUES ('9d87ce85-1254-4b22-9c15-228f11dc7c0b', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'bb45f1cd-a048-4c01-bf0d-30e183029ea3', 'Linatab E 10mg Tab', 30, 25.83, 30, 0, NULL, NULL, 'BATCH-1763741384963', '2025-11-21 16:09:44.978', '2025-11-21 16:09:44.978');
INSERT INTO public.inventory_items VALUES ('aaef4b61-e396-40fc-a2cb-5ad4e35d189e', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3ecb2207-36d7-4b6d-bf82-8985a150fd03', 'Carlina 5mg Tab', 20, 19, 22, 0, NULL, NULL, 'BATCH-1763741509974', '2025-11-21 16:11:49.984', '2025-11-21 16:11:49.984');
INSERT INTO public.inventory_items VALUES ('2b88ee50-bdbc-40c0-8d33-3e3de410e042', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'c5bf7174-4d90-47c7-8f72-0d1a1f53e65c', 'Empaglif 25mg Tab', 30, 41, 50, 0, NULL, NULL, 'BATCH-1763739980619', '2025-11-21 15:46:20.633', '2025-11-21 16:12:32.857');
INSERT INTO public.inventory_items VALUES ('c3e9a6d4-ea28-4ecf-ae74-24a64d5f5819', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '2c4af531-696b-433f-8221-da444b1ae69a', 'Nidocard Retard Tab', 42, 19, 22, 0, NULL, NULL, 'BATCH-1763739961560', '2025-11-21 15:46:01.572', '2025-11-21 16:13:07.231');
INSERT INTO public.inventory_items VALUES ('dad22918-ee40-4b09-aa91-a970b8576fb2', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '9af9f865-d3dd-4ecc-91ba-78d7da227393', 'Cardobis Plus 5/6.25 Tab', 30, 9.68, 11, 0, NULL, NULL, 'BATCH-1763741657744', '2025-11-21 16:14:17.757', '2025-11-21 16:14:17.757');
INSERT INTO public.inventory_items VALUES ('eab9f42a-dabc-4095-953d-1baf71c7bb35', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'e26807fc-008a-4928-9541-e8b4da9baf4b', 'Riboflavin', 500, 0.14, 0.5, 0, NULL, NULL, 'BATCH-1763741782504', '2025-11-21 16:16:22.518', '2025-11-21 16:16:22.518');
INSERT INTO public.inventory_items VALUES ('8e21ef1a-66fa-49c3-a77c-6098f6b2b4c9', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3b5291bf-f7ea-4a21-8d3e-0f953e80d9a2', 'Ramoril 2.5mg', 20, 4.4, 5, 0, NULL, NULL, 'BATCH-1763741896136', '2025-11-21 16:18:16.148', '2025-11-21 16:18:16.148');
INSERT INTO public.inventory_items VALUES ('c9c29b6c-ddad-4503-89d4-8199730a1e68', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '2ba025ff-8071-4b56-ba72-b370fb356c9c', 'Calamilon', 2, 60, 100, 0, NULL, NULL, 'BATCH-1763739259920', '2025-11-21 15:34:19.932', '2025-11-22 06:30:36.782');
INSERT INTO public.inventory_items VALUES ('8442dbc5-d02d-4a5f-8c8d-5b25ba719192', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '85c4a45c-c6a6-4296-a6c2-ce753da4e430', 'Flacol', 2, 35, 40, 0, NULL, NULL, 'BATCH-1763739146062', '2025-11-21 15:32:26.077', '2025-11-22 06:42:44.266');
INSERT INTO public.inventory_items VALUES ('4c87307e-1f87-45af-a3a2-d59b5da6a4c5', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '54c115e0-f005-45ea-827d-e3a9ea4aebc7', 'Thyrin 25mcg Tab', 45, 0.978, 1.133, 0, NULL, NULL, 'BATCH-1763741986346', '2025-11-21 16:19:46.358', '2025-11-21 16:19:46.358');
INSERT INTO public.inventory_items VALUES ('fd23bdf4-268f-4a2e-87ff-27d4ba3346ae', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'dd1d28c3-30c4-47c4-927d-329dd8e28fb5', 'Riboson 5mg Tab', 500, 0.25, 0.5, 0, NULL, NULL, 'BATCH-1763742054114', '2025-11-21 16:20:54.125', '2025-11-21 16:20:54.125');
INSERT INTO public.inventory_items VALUES ('e9d525b8-2783-4587-8414-9fdd4b0707e1', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '496de5f3-299c-409b-9222-1a0c3dfc1dda', 'Amdocal 5mg Tab', 105, 4.76, 5.5, 0, NULL, NULL, 'BATCH-1763742150913', '2025-11-21 16:22:30.924', '2025-11-21 16:22:30.924');
INSERT INTO public.inventory_items VALUES ('1ce9f4b9-66d6-4402-8f24-a6ad7f8b9c8b', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '1f22ef2a-749f-4c71-a949-e0808654566b', 'Telmipres 40mg Tab', 10, 7.82, 9, 0, NULL, NULL, 'BATCH-1763742200134', '2025-11-21 16:23:20.149', '2025-11-21 16:23:20.149');
INSERT INTO public.inventory_items VALUES ('25344e73-bc81-4683-a9fc-9cb80919d1a0', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd25e3519-8aaa-4681-94f0-3c7707dc81a1', 'Thyrox 50mg Tab', 120, 1.944, 2.2, 0, NULL, NULL, 'BATCH-1763742310040', '2025-11-21 16:25:10.052', '2025-11-21 16:26:21.5');
INSERT INTO public.inventory_items VALUES ('15091cf9-eedd-4cec-a170-4cf444f8e523', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '25f6e022-79f3-4451-8f79-85a55e7d4a27', 'Thyrox 25mg Tab', 90, 0.9776, 1.1666, 0, NULL, NULL, 'BATCH-1763742489261', '2025-11-21 16:28:09.274', '2025-11-21 16:28:09.274');
INSERT INTO public.inventory_items VALUES ('7ee87cf7-48bd-405a-8eae-de45f58150db', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'c3201df2-1081-4b19-9c9c-74e096f16b40', 'Angilock Plus 50/12.5', 20, 7, 10, 0, NULL, NULL, 'BATCH-1763742593596', '2025-11-21 16:29:53.613', '2025-11-21 16:29:53.613');
INSERT INTO public.inventory_items VALUES ('7fd78e43-27de-4c3e-88dd-fb937db0859a', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3082b783-988a-4194-b019-4a51b5f7bb0a', 'Prasurel 10mg Tab', 20, 17.5, 20, 0, NULL, NULL, 'BATCH-1763742803361', '2025-11-21 16:33:23.372', '2025-11-21 16:33:23.372');
INSERT INTO public.inventory_items VALUES ('c7f19a1e-15b4-48b7-852a-c436d78322af', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '69a1f8b3-22d6-4afe-a8c2-a59bc8ef8fa5', 'Nidipine SR-20 Tab', 100, 0.58, 0.7, 0, NULL, NULL, 'BATCH-1763742889959', '2025-11-21 16:34:49.98', '2025-11-21 16:35:52.556');
INSERT INTO public.inventory_items VALUES ('0dcd0af3-edf2-41c1-87eb-62c201f2484f', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '2f93c069-41fe-4cf4-9d96-5d6ddf914843', 'ATV 10mg Tab', 30, 4.33, 5, 0, NULL, NULL, 'BATCH-1763743046593', '2025-11-21 16:37:26.606', '2025-11-21 16:37:26.606');
INSERT INTO public.inventory_items VALUES ('60ecc46a-e6ca-40f3-a88f-f337980efb4e', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '528c7d03-043c-48d3-9936-7e7a8c1964e9', 'Creston 10mg Tab', 30, 16.67, 20, 0, NULL, NULL, 'BATCH-1763743221612', '2025-11-21 16:40:21.632', '2025-11-21 16:40:21.632');
INSERT INTO public.inventory_items VALUES ('6ad373c8-e205-4eb1-bf00-831e593fdfc9', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '7aed27f9-8d03-4381-ad76-fbe20559ad33', 'Rosu 20mg Tab', 30, 25.33, 30, 0, NULL, NULL, 'BATCH-1763743274555', '2025-11-21 16:41:14.567', '2025-11-21 16:41:14.567');
INSERT INTO public.inventory_items VALUES ('ee76b660-16ba-4e60-8d28-c2a157a772a5', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '424d8d10-bf75-4097-83b3-04cc8c3b91c9', 'Paloxi Tab', 30, 16.67, 20, 0, NULL, NULL, 'BATCH-1763743485784', '2025-11-21 16:44:45.794', '2025-11-21 16:44:45.794');
INSERT INTO public.inventory_items VALUES ('52b0ddac-1ba4-4d17-b12e-fac89f68f52c', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'a6276221-ebd7-4298-86da-6cd2d243ec0d', 'Rovast 5mg Tab', 30, 8.67, 10, 0, NULL, NULL, 'BATCH-1763743594913', '2025-11-21 16:46:34.932', '2025-11-21 16:46:34.932');
INSERT INTO public.inventory_items VALUES ('9a3c01f7-5347-4e73-9fa4-e76ab68ef777', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3880f7a6-20c9-4f42-b82e-ab99b4389d27', 'Rosuva 10mg Tab', 20, 18.67, 22, 0, NULL, NULL, 'BATCH-1763743639561', '2025-11-21 16:47:19.569', '2025-11-21 16:47:19.569');
INSERT INTO public.inventory_items VALUES ('282fbf24-cb28-4584-83a6-f25f0448a445', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'f9ddc938-0bca-4cd7-8b2a-4271b215811e', 'Atova 10mg Tab', 30, 10.33, 12, 0, NULL, NULL, 'BATCH-1763743669640', '2025-11-21 16:47:49.65', '2025-11-21 16:47:49.65');
INSERT INTO public.inventory_items VALUES ('b631a715-a144-458b-a41a-a4af74ff3759', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'c02b4cee-d12a-4bcf-997e-966c020d26bb', 'Monas 10mg Tab', 6, 13, 17, 0, NULL, NULL, 'BATCH-1763743715138', '2025-11-21 16:48:35.149', '2025-11-21 16:48:35.149');
INSERT INTO public.inventory_items VALUES ('876cbce2-7672-4b64-b9ed-e6695b1e03be', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '585e089e-fc7c-4ceb-9682-5f56c8266322', 'Atova 20mg Tab', 30, 17.6, 20, 0, NULL, NULL, 'BATCH-1763743812109', '2025-11-21 16:50:12.118', '2025-11-21 16:50:12.118');
INSERT INTO public.inventory_items VALUES ('7daa4c39-b1d9-43a3-a737-d6e491f0b313', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '6bc333ea-0ba3-4f7b-986e-fb68d7bb777f', 'Ecosprin 75mg Tab', 400, 0.725, 0.8, 0, NULL, NULL, 'BATCH-1763743921573', '2025-11-21 16:52:01.586', '2025-11-21 16:52:01.586');
INSERT INTO public.inventory_items VALUES ('1ec1628f-82ca-4d45-8dc4-c3c5ea99cde9', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'ae3f130a-aab6-45ed-8622-68cf89246ec2', 'Montene 10mg Tab', 14, 14.33, 17, 0, NULL, NULL, 'BATCH-1763743989728', '2025-11-21 16:53:09.738', '2025-11-21 16:53:09.738');
INSERT INTO public.inventory_items VALUES ('6d3854dc-186e-467e-8faf-7b1a78a1128c', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '52afb0c0-700c-4144-a587-46d9b9b437e6', 'Hemorif Tab', 30, 6.83, 8, 0, NULL, NULL, 'BATCH-1763744033025', '2025-11-21 16:53:53.034', '2025-11-21 16:53:53.034');
INSERT INTO public.inventory_items VALUES ('24e40b34-5c59-4457-b545-367b62d7c8b2', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3e124afe-80d0-4324-931b-a1d10bf83f13', 'Anclog Plus 75mg Tab', 30, 10.38, 12, 0, NULL, NULL, 'BATCH-1763744101476', '2025-11-21 16:55:01.486', '2025-11-21 16:55:11.119');
INSERT INTO public.inventory_items VALUES ('adac454b-c5a7-463a-810d-feac580592e0', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '06c213a6-344a-4582-84a7-c98bc8b5ead9', 'Montene 4mg', 12, 4, 7, 0, NULL, NULL, 'BATCH-1763744173777', '2025-11-21 16:56:13.79', '2025-11-21 16:56:13.79');
INSERT INTO public.inventory_items VALUES ('929636f7-42f1-4b8e-972b-304c2c50628b', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '4e5fca3a-e731-477d-821f-336a80a212f1', 'Diamicron MR 60mg Tab', 60, 18, 22, 0, NULL, NULL, 'BATCH-1763744217683', '2025-11-21 16:56:57.693', '2025-11-21 16:56:57.693');
INSERT INTO public.inventory_items VALUES ('698512c9-a0d0-4284-bf06-25e3d6097902', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3d0030c3-fd96-4c34-8cc2-bacda95a1cce', 'Arovent 10mg Tab', 30, 14.96, 17.5, 0, NULL, NULL, 'BATCH-1763744276984', '2025-11-21 16:57:56.997', '2025-11-21 16:58:05.193');
INSERT INTO public.inventory_items VALUES ('59f706a4-fa57-49d5-96e5-eaf1ad3f1209', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd3b8f7a5-b716-49a6-93c0-cd95e9f04552', 'Lumona 10mg Tab', 28, 10.5, 12, 0, NULL, NULL, 'BATCH-1763744375558', '2025-11-21 16:59:35.567', '2025-11-21 16:59:35.567');
INSERT INTO public.inventory_items VALUES ('33b59c46-6283-479a-889e-c3fbeb3dbb09', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'fe05e82b-0ded-4bd8-9344-5a7fdeb555b4', 'Odrel Plug 75mg Tab', 30, 10.5, 12, 0, NULL, NULL, 'BATCH-1763744330451', '2025-11-21 16:58:50.465', '2025-11-21 16:59:43.595');
INSERT INTO public.inventory_items VALUES ('a369aa86-3391-4f57-bfa6-059ff0a50e8d', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '541ae51c-6b9d-4a54-a706-fe48aecb61fd', 'Imotil 2mg Tab', 190, 0.85, 1, 0, NULL, NULL, 'BATCH-1763746991457', '2025-11-21 17:43:11.467', '2025-11-21 17:43:11.467');
INSERT INTO public.inventory_items VALUES ('79dabd7a-bdab-461f-b31b-c6c0e2c51f81', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'e3f7c84a-03cb-4e97-84ef-5e7e4790ecc5', 'Flagyl 400mg Tab', 270, 1.5, 2, 0, NULL, NULL, 'BATCH-1763747013861', '2025-11-21 17:43:33.868', '2025-11-21 17:43:47.797');
INSERT INTO public.inventory_items VALUES ('3b10c249-12c0-46ec-b0d0-f380981a56be', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3f9f8c2e-ff8a-423e-8325-e780421553dd', 'Filmet 400mg Tab', 250, 1.5, 2, 0, NULL, NULL, 'BATCH-1763747051241', '2025-11-21 17:44:11.252', '2025-11-21 17:44:11.252');
INSERT INTO public.inventory_items VALUES ('03675712-a1ac-408d-9b80-81c317ba6e33', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd6606dda-bf54-4c35-8b85-28e54281e40f', 'Linax Plus 2.5/850 Tab', 60, 8, 10, 0, NULL, NULL, 'BATCH-1763747085967', '2025-11-21 17:44:45.975', '2025-11-21 17:44:45.975');
INSERT INTO public.inventory_items VALUES ('5b0ac609-1796-4e9b-8b20-8c52ea43cecd', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '9059139f-a0a1-4b77-9570-dd71a046d150', 'Linax Plus 2.5/500 Tab', 60, 7.92, 9, 0, NULL, NULL, 'BATCH-1763747157686', '2025-11-21 17:45:57.694', '2025-11-21 17:45:57.694');
INSERT INTO public.inventory_items VALUES ('53952f43-2375-4dbc-a2aa-9812853cdd5a', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'b660c68c-c11b-4e3f-bdf7-f7901ec78bd1', 'Calbo-D Tab', 60, 6.67, 8, 0, NULL, NULL, 'BATCH-1763747243682', '2025-11-21 17:47:23.695', '2025-11-21 17:47:23.695');
INSERT INTO public.inventory_items VALUES ('cdace4a3-c30f-45bf-a181-2a99e4da3e85', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'a3df3443-a917-4e67-90d9-d980596cb5fd', 'Calboral-D Tab', 60, 9, 11, 0, NULL, NULL, 'BATCH-1763747291511', '2025-11-21 17:48:11.519', '2025-11-21 17:48:11.519');
INSERT INTO public.inventory_items VALUES ('7c49e986-f9b2-46e7-90da-5a5d42161a61', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '60f53811-0a66-4916-8018-169a0f5a186c', 'G-Calbo Tab', 90, 9, 11, 0, NULL, NULL, 'BATCH-1763747314975', '2025-11-21 17:48:34.984', '2025-11-21 17:50:53.936');
INSERT INTO public.inventory_items VALUES ('ba856817-fc2e-45cc-a98c-e16f80c509ac', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'e2c2a40a-b481-4890-a7c4-8a56400c34af', 'Calboplex Tab', 60, 5.16, 6, 0, NULL, NULL, 'BATCH-1763747534462', '2025-11-21 17:52:14.473', '2025-11-21 17:52:14.473');
INSERT INTO public.inventory_items VALUES ('fc95af87-4df0-4494-859c-b9c92f359aad', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'a3716c40-0d7c-4613-a512-59c07054221d', 'Dialiptin-M 850mg', 14, 14.72, 19, 0, NULL, NULL, 'BATCH-1763747661978', '2025-11-21 17:54:21.988', '2025-11-21 17:54:21.988');
INSERT INTO public.inventory_items VALUES ('0fc92e79-bdb7-492e-a282-b063d5810806', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'e32ff413-4f0f-4991-9397-354f60252315', 'Filwel Silver A to Z Tab', 30, 9, 12, 0, NULL, NULL, 'BATCH-1763747717224', '2025-11-21 17:55:17.232', '2025-11-21 17:55:17.232');
INSERT INTO public.inventory_items VALUES ('dc47cbae-c8b1-4d0c-914b-17e3161bf813', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'e32ff413-4f0f-4991-9397-354f60252315', 'Filwel Silver A to Z Tab - Standard', 60, 10.167, 12, 0, NULL, NULL, 'BATCH-1763747774442', '2025-11-21 17:56:14.456', '2025-11-21 17:56:14.456');
INSERT INTO public.inventory_items VALUES ('3aaead68-6558-4316-9770-28e4d3e3ccba', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '60651f63-f6d2-4a4e-a1b4-0a1229158eca', 'Filwel Gold A to Z Tab', 10, 9, 12, 0, NULL, NULL, 'BATCH-1763747886722', '2025-11-21 17:58:06.73', '2025-11-21 17:58:06.73');
INSERT INTO public.inventory_items VALUES ('d29e5b0d-148d-47ad-984f-512c87815a87', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '60651f63-f6d2-4a4e-a1b4-0a1229158eca', 'Filwel Gold A to Z Tab - Standard', 60, 10.167, 12, 0, NULL, NULL, 'BATCH-1763747945979', '2025-11-21 17:59:05.982', '2025-11-21 17:59:05.982');
INSERT INTO public.inventory_items VALUES ('335cd5d3-e680-4156-a727-01cd6039a39d', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '9e5e39e3-58e2-48ab-9476-3e17a952a3c1', 'Uromax 0.4mg Tab', 20, 10, 12, 0, NULL, NULL, 'BATCH-1763748076391', '2025-11-21 18:01:16.404', '2025-11-21 18:01:16.404');
INSERT INTO public.inventory_items VALUES ('3eb26148-f39e-49cd-a7b9-1f0cba3e656e', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'a5dca170-c11b-4d3c-bf1b-9ca8d79d14f6', 'Xinc B Tab', 80, 2, 3.5, 0, NULL, NULL, 'BATCH-1763748048526', '2025-11-21 18:00:48.542', '2025-11-21 18:01:43.774');
INSERT INTO public.inventory_items VALUES ('aa17f38b-fe5e-4eff-bd0a-116f551306f5', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'b809e61e-e4c5-4bd7-ab36-dd1208db38ce', 'Glucomin 850mg Tab', 50, 5.28, 6, 0, NULL, NULL, 'BATCH-1763748139391', '2025-11-21 18:02:19.399', '2025-11-21 18:02:19.399');
INSERT INTO public.inventory_items VALUES ('7c4a5994-53f9-4a48-8c33-e68e210925d6', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd9f7f0df-5fae-49a6-b388-3dc95d6c3616', 'Calboral-DX Tab', 60, 13.33, 16, 0, NULL, NULL, 'BATCH-1763748202905', '2025-11-21 18:03:22.933', '2025-11-21 18:03:22.933');
INSERT INTO public.inventory_items VALUES ('1abaf52b-20af-4960-8b1f-a5792b1077b5', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'bee2a558-7c70-4e43-89eb-ef6eac27739f', 'Metfo XR 500mg Tab', 50, 6.1, 7, 0, NULL, NULL, 'BATCH-1763748266122', '2025-11-21 18:04:26.13', '2025-11-21 18:04:26.13');
INSERT INTO public.inventory_items VALUES ('93516754-9164-40b4-992b-c55c32a855a5', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'ab26e9c9-c39f-420c-883f-f158af445b38', 'Calbotol Tab', 30, 11, 13, 0, NULL, NULL, 'BATCH-1763748289889', '2025-11-21 18:04:49.897', '2025-11-21 18:04:49.897');
INSERT INTO public.inventory_items VALUES ('f91372ac-9daa-48c3-9539-c1c93d97194c', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '0b7cecf5-7389-441d-b9f2-50e9ac194c82', 'Nitrocontin 6.4mg Tab', 30, 8, 9, 0, NULL, NULL, 'BATCH-1763748373956', '2025-11-21 18:06:13.965', '2025-11-21 18:06:13.965');
INSERT INTO public.inventory_items VALUES ('6bf220a5-82fe-4911-9806-992c854e3cb6', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '8ebc8034-4965-460f-a6bf-a96017c5f03a', 'Nobesit 500mg Tab', 60, 3.5, 4, 0, NULL, NULL, 'BATCH-1763748395554', '2025-11-21 18:06:35.564', '2025-11-21 18:06:35.564');
INSERT INTO public.inventory_items VALUES ('24ac47dc-f6de-4730-aff7-55e539790052', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'fcad7251-8610-4938-ae5c-47e50dcb0b37', 'Met 850mg Tab', 60, 5.08, 6, 0, NULL, NULL, 'BATCH-1763748421439', '2025-11-21 18:07:01.447', '2025-11-21 18:07:01.447');
INSERT INTO public.inventory_items VALUES ('6c6ce206-41e0-448a-8efe-561345392e90', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '99a4023b-91e2-4275-ae1e-8df4296adaa4', 'Comet 850mg Tab', 50, 5.2, 6, 0, NULL, NULL, 'BATCH-1763748440916', '2025-11-21 18:07:20.924', '2025-11-21 18:07:20.924');
INSERT INTO public.inventory_items VALUES ('578d5e94-b6f9-41de-9aef-c1bc3955b46f', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '2e64bece-1f47-48de-8097-0fb0ed261b14', 'Siglimet 50/500 Tab', 30, 14.08, 16, 0, NULL, NULL, 'BATCH-1763748466314', '2025-11-21 18:07:46.323', '2025-11-21 18:07:46.323');
INSERT INTO public.inventory_items VALUES ('6ad511fb-4f33-4276-9d0e-1567f9ba1fcd', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'a09ab0a6-2432-41cb-aaee-5fd8af20f8f7', 'Dimerol 80mg', 53, 7.05, 8, 0, NULL, NULL, 'BATCH-1763748583962', '2025-11-21 18:09:43.974', '2025-11-21 18:15:50.955');
INSERT INTO public.inventory_items VALUES ('d8c56e27-5bf3-4c3d-b345-5c92590479c2', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'ddfdc607-0dcd-41ca-bab5-2002ee92715c', 'Emjard M XR 5/1000mg', 20, 21, 25, 0, NULL, NULL, 'BATCH-1763749010159', '2025-11-21 18:16:50.197', '2025-11-21 18:16:50.197');
INSERT INTO public.inventory_items VALUES ('9757e970-7f20-4e12-aa3f-bcdfabb508a4', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '5c4740b5-207a-46f0-b7b5-d04d2436d8a8', 'Comet 500mg Tab', 60, 4.3, 5, 0, NULL, NULL, 'BATCH-1763749049480', '2025-11-21 18:17:29.488', '2025-11-21 18:17:29.488');
INSERT INTO public.inventory_items VALUES ('7e9bab1a-73c9-4f3d-a479-9ca590dc18ac', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'ce3843a6-f8ba-4ae7-9eeb-026249e1ac91', 'Bextram Silver A to Z', 14, 6.43, 12, 0, NULL, NULL, 'BATCH-1763750768348', '2025-11-21 18:46:08.359', '2025-11-21 18:47:42.663');
INSERT INTO public.inventory_items VALUES ('098eedb5-bcb7-4e36-a48f-0a6a023981d5', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '384b44db-c9e3-4de9-b994-bde0d972443f', 'Comprid 80mg', 40, 6.83, 8, 0, NULL, NULL, 'BATCH-1763750977475', '2025-11-21 18:49:37.487', '2025-11-21 18:49:37.487');
INSERT INTO public.inventory_items VALUES ('d0f2234b-ea17-439e-afd0-5066d4b880d9', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'a9f086b6-d7ae-48e6-a554-451992bb079a', 'Diapro 60 MR', 20, 10.56, 12, 0, NULL, NULL, 'BATCH-1763751129877', '2025-11-21 18:52:09.893', '2025-11-21 18:52:09.893');
INSERT INTO public.inventory_items VALUES ('4104f50c-7983-4ed6-8b8d-4e4d5fa9c7f3', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '01cc0e69-718a-4c6d-8ee9-d855a0148642', 'Emjard M XR 25/1000', 20, 41, 50, 0, NULL, NULL, 'BATCH-1763751251377', '2025-11-21 18:54:11.387', '2025-11-21 18:54:11.387');
INSERT INTO public.inventory_items VALUES ('74eb813b-eb75-49d9-becd-c850237e08d5', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'cfd5b1d5-106f-472c-853f-683943afdca6', 'Bextram Gold A to Z', 14, 7.142, 12, 0, NULL, NULL, 'BATCH-1763751820303', '2025-11-21 19:03:40.314', '2025-11-21 19:03:40.314');
INSERT INTO public.inventory_items VALUES ('91366a5b-bf73-4a9d-827d-6f4a9c658618', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'a5e7ba1f-0657-4545-8576-63b9427d3f46', 'Multivit plus', 80, 1.75, 2.5, 0, NULL, NULL, 'BATCH-1763752095271', '2025-11-21 19:08:15.279', '2025-11-21 19:08:15.279');
INSERT INTO public.inventory_items VALUES ('0514b9b8-a245-466c-bcea-f1a8ff963692', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'a5e7ba1f-0657-4545-8576-63b9427d3f46', 'Multivit plus - Standard', 60, 2.167, 2.5, 0, NULL, NULL, 'BATCH-1763752206788', '2025-11-21 19:10:06.792', '2025-11-21 19:10:06.792');
INSERT INTO public.inventory_items VALUES ('4380b5fc-4072-4a80-b889-8b33d18f6641', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '4b47e18b-af51-4cc8-abdb-b3e931aad102', 'Vildapin Plus 500mg Tab', 20, 14.72, 19, 0, NULL, NULL, 'BATCH-1763747860357', '2025-11-21 17:57:40.366', '2025-11-21 19:26:49.095');
INSERT INTO public.inventory_items VALUES ('bf67c094-9833-4892-8896-278e88c0d3f4', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '7c3d1693-7726-4316-94f7-db833c82ca90', 'Prasurel 5mg Tab', 20, 10.5, 12, 0, NULL, NULL, 'BATCH-1763742830817', '2025-11-21 16:33:50.832', '2025-11-21 19:28:49.826');
INSERT INTO public.inventory_items VALUES ('25aea772-2943-4968-8cd8-1a81b3d87196', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '41445f5c-0965-41b6-bca5-6fb37ee75a15', 'Betaloc 25mg Tab', 107, 1.38, 1.55, 0, NULL, NULL, 'BATCH-1763740092216', '2025-11-21 15:48:12.228', '2025-11-21 19:30:35.718');
INSERT INTO public.inventory_items VALUES ('6dcc37be-b700-42cb-a92f-0a969e4bfa6a', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '6e865177-c4e8-4b50-8e40-ef563eeb6f67', 'V-Plex ampoule', 8, 9, 30, 0, NULL, NULL, 'BATCH-1763751986480', '2025-11-21 19:06:26.494', '2025-11-22 00:47:34.731');
INSERT INTO public.inventory_items VALUES ('92ff3693-08d1-44c4-8a24-e624bfc42fa1', 'bbfe6914-675b-4dd6-a172-d1c637e75e27', 'd7e77ab9-7ae9-47ef-b72c-9d53ef0f2711', 'napa', 9, 8, 10, 0, NULL, NULL, 'BATCH-1763762792318', '2025-11-21 22:06:32.64', '2025-11-21 22:06:53.703');
INSERT INTO public.inventory_items VALUES ('e47272b8-5355-49ac-b0ec-52de45339b5a', 'bbfe6914-675b-4dd6-a172-d1c637e75e27', 'a16f14ce-1b2e-4555-99b1-c1b8428a645d', 'biloba', 47, 6, 10, 0, NULL, NULL, 'BATCH-1763762802166', '2025-11-21 22:06:42.341', '2025-11-21 22:07:25.61');
INSERT INTO public.inventory_items VALUES ('74e46c5b-4eb8-492e-9256-e1757fe4057a', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'caac663b-1c7b-4e68-b37d-e903ca1b3cfa', 'Freedome Sanitary Napkin RFP 240mm', 13, 38, 45, 0, NULL, NULL, 'BATCH-1763790454488', '2025-11-22 05:47:34.502', '2025-11-22 05:47:34.502');
INSERT INTO public.inventory_items VALUES ('315b63d6-8938-4d8a-bcb3-e9ef5b4b5ca9', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '4c5e82d0-c2a4-485f-a176-8af57ee4b910', 'Twinkle Baby Diaper XXL 24pc', 1, 600, 650, 0, NULL, NULL, 'BATCH-1763790738163', '2025-11-22 05:52:18.18', '2025-11-22 05:52:18.18');
INSERT INTO public.inventory_items VALUES ('ddcc577f-671d-4ed7-bc40-ea8916be4840', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'b0b45df6-6a81-4d4d-b11d-4d4895f947fc', 'Twinkle Baby Diaper M 40pc', 1, 600, 650, 0, NULL, NULL, 'BATCH-1763790787187', '2025-11-22 05:53:07.195', '2025-11-22 05:53:07.195');
INSERT INTO public.inventory_items VALUES ('749e4f61-6044-4874-ac34-0c5a3f64ce9f', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '28fba87b-5fbd-40d6-a1e5-f0a308020617', 'Twinkle Baby Diaper S 42pc', 1, 600, 650, 0, NULL, NULL, 'BATCH-1763790820456', '2025-11-22 05:53:40.472', '2025-11-22 05:53:40.472');
INSERT INTO public.inventory_items VALUES ('f21d7523-aec8-418d-a328-d739f22e0e92', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd34dd1da-58c9-4ea9-a062-39c3d6e86c35', 'Twinkle Baby Diaper XL 32pc', 1, 600, 650, 0, NULL, NULL, 'BATCH-1763790852718', '2025-11-22 05:54:12.728', '2025-11-22 05:54:12.728');
INSERT INTO public.inventory_items VALUES ('463200f5-5cdc-40e1-be68-8db657006e59', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '03c2981f-dbc1-4bb0-bc38-d8269a54959f', 'Twinkle Baby Diaper L 34pc', 1, 600, 650, 0, NULL, NULL, 'BATCH-1763790890956', '2025-11-22 05:54:50.976', '2025-11-22 05:54:50.976');
INSERT INTO public.inventory_items VALUES ('7db5d58c-6b04-4fe6-a100-770fed0869f1', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd954d3a4-94b8-48ee-b60f-5244a26da1ba', 'Twinkle Baby Diaper S 5pc', 2, 85, 100, 0, NULL, NULL, 'BATCH-1763791873580', '2025-11-22 06:11:13.589', '2025-11-22 06:11:13.589');
INSERT INTO public.inventory_items VALUES ('642df85a-1a2d-4100-aabd-baf6b048f948', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '8ace8549-c2f8-4327-9e83-84cf7c98ced3', 'Twinkle Baby Diaper XL 5pc', 2, 85, 100, 0, NULL, NULL, 'BATCH-1763791885719', '2025-11-22 06:11:25.728', '2025-11-22 06:11:25.728');
INSERT INTO public.inventory_items VALUES ('22c27658-d517-4216-831d-06bda002c39d', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'ee9e1eb8-e461-4fdc-9331-a75d84f3afaa', 'Twinkle Baby Diaper XXL 5pc', 2, 85, 100, 0, NULL, NULL, 'BATCH-1763791901897', '2025-11-22 06:11:41.906', '2025-11-22 06:11:41.906');
INSERT INTO public.inventory_items VALUES ('dae887a1-eb84-4c85-8fcc-9ea44e7f9447', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '21999888-0244-4e73-b704-bc917c14a773', 'Twinkle Baby Diaper SL 5pc', 2, 85, 100, 0, NULL, NULL, 'BATCH-1763791908909', '2025-11-22 06:11:48.92', '2025-11-22 06:11:48.92');
INSERT INTO public.inventory_items VALUES ('ee1bd0eb-93e9-42e2-b032-8e9103f96b1c', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '154fda53-e8dc-47e6-b386-c7068e6980ba', 'Twinkle Baby Diaper M 5pc', 1, 85, 100, 0, NULL, NULL, 'BATCH-1763791806816', '2025-11-22 06:10:06.832', '2025-11-22 06:15:10.303');
INSERT INTO public.inventory_items VALUES ('0ceccdda-15b8-4e92-bb71-80c75f3010c8', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'be6899f1-6147-4c08-ac0f-96fe7dc2adb7', 'Freedom Sanitary Napkin Soft 16pc', 2, 155, 200, 0, NULL, NULL, 'BATCH-1763792365231', '2025-11-22 06:19:25.246', '2025-11-22 06:19:25.246');
INSERT INTO public.inventory_items VALUES ('5da9732f-084e-4026-9d00-7bdac616e1cc', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'c9c02659-64c1-4c2c-aea8-db974d2e053c', 'Freedom Sanitary Napkin Soft 8pc', 2, 90, 120, 0, NULL, NULL, 'BATCH-1763792379183', '2025-11-22 06:19:39.196', '2025-11-22 06:19:39.196');
INSERT INTO public.inventory_items VALUES ('6a4d0688-1b0f-4009-9691-d67868b6d27b', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'f9b8e7ad-520e-4b4a-9da6-76fea46a375d', 'Mum Mum Baby Diaper L 5pc', 4, 80, 100, 0, NULL, NULL, 'BATCH-1763792440824', '2025-11-22 06:20:40.834', '2025-11-22 06:21:11.281');
INSERT INTO public.inventory_items VALUES ('c39a6eb8-cfb5-411f-a4d5-9e52e639c47a', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '68751ddc-272d-48c5-b5be-e618482ea722', 'Mum Mum Baby Diaper M 5pc', 3, 80, 100, 0, NULL, NULL, 'BATCH-1763792487543', '2025-11-22 06:21:27.554', '2025-11-22 06:21:27.554');
INSERT INTO public.inventory_items VALUES ('285f973b-1f14-404a-836c-7f0f3d72788e', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'b364871b-e1cf-4a04-9b33-574240454aeb', 'Mum Mum Baby Diaper XL 5pc', 2, 80, 100, 0, NULL, NULL, 'BATCH-1763792529751', '2025-11-22 06:22:09.761', '2025-11-22 06:22:09.761');
INSERT INTO public.inventory_items VALUES ('81b1aeb1-3d12-4fe0-9f9d-90d4eee938c0', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'ecc3d6e7-115d-4f24-b58b-7c7cb9a21989', 'Mum Mum Baby Diaper XXL 5pc', 2, 80, 100, 0, NULL, NULL, 'BATCH-1763792536678', '2025-11-22 06:22:16.69', '2025-11-22 06:22:16.69');
INSERT INTO public.inventory_items VALUES ('f00dd532-d6e1-4881-a118-c9189983b557', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'dd2c05d7-3b63-45c6-8ea0-f55afc3f9cdf', 'Mum Mum Baby Diaper S 5pc', 2, 80, 100, 0, NULL, NULL, 'BATCH-1763792546832', '2025-11-22 06:22:26.841', '2025-11-22 06:22:26.841');
INSERT INTO public.inventory_items VALUES ('5fd366ec-e7ef-4fcc-85b3-567e7c1bc4bc', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'fe7d0e80-b0c7-4fc6-8b41-9aa9649e73e0', 'Rex', 60, 3, 3.5, 0, NULL, NULL, 'BATCH-1763792912604', '2025-11-22 06:28:32.616', '2025-11-22 06:30:14.142');
INSERT INTO public.inventory_items VALUES ('6100fe24-366a-431b-8b2f-d62176040f26', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'e6fa8446-c578-42b4-88f4-5b3f55a62398', 'Zanthin 4', 30, 18.67, 22, 0, NULL, NULL, 'BATCH-1763793440703', '2025-11-22 06:37:20.72', '2025-11-22 06:37:20.72');
INSERT INTO public.inventory_items VALUES ('ca77221c-0b88-427b-898c-552eb215aff2', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'b32327d9-0710-44fa-872d-f223f27d4654', 'Zif-Cl', 60, 4.4, 5, 0, NULL, NULL, 'BATCH-1763793494230', '2025-11-22 06:38:14.244', '2025-11-22 06:38:14.244');
INSERT INTO public.inventory_items VALUES ('676ef4c8-a19a-4276-8f4d-6e9c8f349442', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '17386eda-fbd7-4e2a-961e-2f0c702e68bb', 'Ostocal G', 40, 9.68, 11, 0, NULL, NULL, 'BATCH-1763793558980', '2025-11-22 06:39:18.991', '2025-11-22 06:39:18.991');
INSERT INTO public.inventory_items VALUES ('5c295311-d80b-4a65-b775-bfaaeb1a6d98', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '99a5297c-7395-4828-bf8f-1a9692ced565', 'Calcin-D', 60, 6.67, 8, 0, NULL, NULL, 'BATCH-1763793616218', '2025-11-22 06:40:16.229', '2025-11-22 06:40:16.229');
INSERT INTO public.inventory_items VALUES ('1f0610d3-3b41-4adc-80b7-3e27e5fb3538', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3213ccd8-c615-4ec1-a848-a1830613ac2b', 'Calmet D', 120, 6.16, 7, 0, NULL, NULL, 'BATCH-1763793863827', '2025-11-22 06:44:23.859', '2025-11-22 06:44:23.859');
INSERT INTO public.inventory_items VALUES ('56a43f03-fe38-4dfa-80f5-748a81a401cb', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '682acf5e-73f9-4592-9034-cc4a06271e22', 'Ciprocin 0.3% Eye Drop', 1, 44, 50, 0, NULL, NULL, 'BATCH-1763793889399', '2025-11-22 06:44:49.727', '2025-11-22 06:44:49.727');
INSERT INTO public.inventory_items VALUES ('ed31582f-d39c-4bc9-b51c-9b8551d58f66', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '915208c4-e2dd-43c3-b978-4e741693f230', 'Povisep 10% Antiseptic Solution', 2, 48.4, 55, 0, NULL, NULL, 'BATCH-1763793940423', '2025-11-22 06:45:40.643', '2025-11-22 06:45:40.643');
INSERT INTO public.inventory_items VALUES ('e26130c2-a105-4597-8afe-b51144bbc329', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'e198da08-0b40-4eed-a46e-6aeb229a68c3', 'Folison 5mg', 500, 0.32, 0.5, 0, NULL, NULL, 'BATCH-1763793962942', '2025-11-22 06:46:02.952', '2025-11-22 06:46:02.952');
INSERT INTO public.inventory_items VALUES ('63e6426c-6542-480d-9fd8-f9c68f211cc8', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '381ccef3-af4d-4d1c-8c1a-b687a771f79b', 'Deslor Syrup 60ml', 3, 26.4, 30, 0, NULL, NULL, 'BATCH-1763793999875', '2025-11-22 06:46:40.204', '2025-11-22 06:46:40.204');
INSERT INTO public.inventory_items VALUES ('f33b25aa-8069-4545-b5c6-e77bccca3e91', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'c1f64388-de12-46fe-aa9c-b0fe32d31d9f', 'Zeefol-Cl', 90, 3.87, 4.5, 0, NULL, NULL, 'BATCH-1763794028071', '2025-11-22 06:47:08.081', '2025-11-22 06:47:08.081');
INSERT INTO public.inventory_items VALUES ('d01df189-c421-4569-ae27-5ff494d20c33', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '62345a9d-9890-4c88-ad7b-5e8df9199e45', 'Ratinol Forte', 60, 1.72, 2, 0, NULL, NULL, 'BATCH-1763794091260', '2025-11-22 06:48:11.285', '2025-11-22 06:48:11.285');
INSERT INTO public.inventory_items VALUES ('aecc5ca6-7724-496c-a24c-41f010722901', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'd76cfce6-68b1-4059-a6d2-112573e5781f', 'Omidon Syrup 60ml', 1, 35, 40, 0, NULL, NULL, 'BATCH-1763794137831', '2025-11-22 06:48:57.999', '2025-11-22 06:48:57.999');
INSERT INTO public.inventory_items VALUES ('194ac1c4-d7bb-42dc-a745-56e2ce01ac6a', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '18654532-9989-4840-8edb-7569d2da913c', 'E-CAP 200 IU', 60, 4.17, 5, 0, NULL, NULL, 'BATCH-1763794136989', '2025-11-22 06:48:57.002', '2025-11-22 06:49:50.771');
INSERT INTO public.inventory_items VALUES ('5b02db13-b979-4390-baba-30392fb75b13', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '553fc8e7-f279-4aac-8076-8bee1f8e4748', 'Pevisone Cream', 5, 61.6, 70, 0, NULL, NULL, 'BATCH-1763794196651', '2025-11-22 06:49:57.034', '2025-11-22 06:49:57.034');
INSERT INTO public.inventory_items VALUES ('6caedf97-e651-459b-9c12-b79c18d22ca6', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '18654532-9989-4840-8edb-7569d2da913c', 'E-CAP 400 IU', 60, 5.75, 7, 0, NULL, NULL, 'BATCH-1763794245582', '2025-11-22 06:50:45.586', '2025-11-22 06:50:45.586');
INSERT INTO public.inventory_items VALUES ('ecd176ac-c520-4723-aae1-96a91fc3ff77', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '6311f89e-677a-448a-bd47-ee29ee893c33', 'Viodin Ointment 5%', 2, 48.4, 55, 0, NULL, NULL, 'BATCH-1763794264271', '2025-11-22 06:51:04.441', '2025-11-22 06:51:04.441');
INSERT INTO public.inventory_items VALUES ('25609c1d-a0ec-4022-b24b-ea62e553d726', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '8c4af296-8d8c-4723-b5e0-46f2bccd25f8', 'CoralMax-D', 60, 9.68, 11, 0, NULL, NULL, 'BATCH-1763794322069', '2025-11-22 06:52:02.081', '2025-11-22 06:52:12.412');
INSERT INTO public.inventory_items VALUES ('3fbc05ff-a6aa-4786-9163-d9ac61ead131', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'f4915819-0eda-4e11-9b19-57c70495351c', 'Exovate N Cream 25g', 4, 79.2, 90, 0, NULL, NULL, 'BATCH-1763794343293', '2025-11-22 06:52:23.464', '2025-11-22 06:52:23.464');
INSERT INTO public.inventory_items VALUES ('65a3e5af-6889-4e22-8301-6a1427776f82', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'e781ed6b-0aaa-47c0-ac6e-42eecae2405c', 'Ertaco Cream 20g', 1, 176, 200, 0, NULL, NULL, 'BATCH-1763794380930', '2025-11-22 06:53:01.096', '2025-11-22 06:53:01.096');
INSERT INTO public.inventory_items VALUES ('03d2589c-78bd-41fa-8b52-273ea79f1cdd', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'b06f98f2-83aa-4df1-91be-edb58d0f3bff', 'Burnsil Cream 25g', 2, 40, 45, 0, NULL, NULL, 'BATCH-1763794432823', '2025-11-22 06:53:52.988', '2025-11-22 06:53:52.988');
INSERT INTO public.inventory_items VALUES ('0358dc85-6e91-451f-b94e-c482814a95c7', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '73bb0068-dc01-4f3d-b189-66efdac73dfa', 'Tridyl Syrup', 2, 110, 125, 0, NULL, NULL, 'BATCH-1763794481829', '2025-11-22 06:54:41.843', '2025-11-22 06:54:41.843');
INSERT INTO public.inventory_items VALUES ('7e08d82a-93f9-4091-b007-fd2a9761dc25', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '4a34cdc9-0c04-43ea-b560-1b8425551c20', 'Eyemox Eye Drop 0.5%', 2, 128, 160, 0, NULL, NULL, 'BATCH-1763794504708', '2025-11-22 06:55:05.026', '2025-11-22 06:55:05.026');
INSERT INTO public.inventory_items VALUES ('3b8ee2ac-dc5e-4848-b227-5aadb832eda7', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'c8e7f48c-6d1d-460a-8627-85804d568bdd', 'Cef-3 Max PD', 1, 180, 250, 0, NULL, NULL, 'BATCH-1763794407900', '2025-11-22 06:53:27.915', '2025-11-22 06:55:18.581');
INSERT INTO public.inventory_items VALUES ('8fc21c0b-c055-4ea2-a1b2-85147f8c4304', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'c504fefa-0316-4ed5-9134-af3e2fe95c54', 'Jasocaine Jelly', 2, 88, 100, 0, NULL, NULL, 'BATCH-1763794563362', '2025-11-22 06:56:03.58', '2025-11-22 06:56:03.58');
INSERT INTO public.inventory_items VALUES ('0c7843e1-f293-4076-b4ae-58f8c3c8e444', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'c8e7f48c-6d1d-460a-8627-85804d568bdd', 'Cef-3 Forte SUS', 1, 300, 350, 0, NULL, NULL, 'BATCH-1763794576227', '2025-11-22 06:56:16.231', '2025-11-22 06:56:16.231');


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.product_variants VALUES ('36e5b2dc-af9a-417a-9bda-da5010f49d1c', 'bd297b26-ed60-475b-b9c0-6279392cff39', 'Standard', 'SKU-1763729433182', 10, '2025-11-21 12:50:33.183', '2025-11-21 12:50:33.183', '2e0136a8-d74a-408d-b8b6-7656732387d4');
INSERT INTO public.product_variants VALUES ('85c4a45c-c6a6-4296-a6c2-ce753da4e430', 'c6e79076-6d3b-490f-b251-5fdf92d9f6e1', 'Standard', 'SKU-1763739146067', 10, '2025-11-21 15:32:26.068', '2025-11-21 15:32:26.068', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('e89238d7-f574-433b-ba11-337f5ccb1858', '7d6c27cb-0845-42ec-8e8f-0e643837ac83', 'Standard', 'SKU-1763739183473', 10, '2025-11-21 15:33:03.474', '2025-11-21 15:33:03.474', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('2ba025ff-8071-4b56-ba72-b370fb356c9c', '726faf10-b8a7-4424-b947-09e20cfd017f', 'Standard', 'SKU-1763739259925', 10, '2025-11-21 15:34:19.926', '2025-11-21 15:34:19.926', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d98cfb38-2288-4231-a690-e3e70b9529c2', '5719086a-4782-4f2e-a853-dae11df9587a', 'Standard', 'SKU-1763739900163', 30, '2025-11-21 15:45:00.164', '2025-11-21 15:45:00.164', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('5c626750-ddc6-4cff-a775-6fd8d6423c71', '8449e4a8-0bb1-4721-8051-2075b98fe9ed', 'Standard', 'SKU-1763739935344', 12, '2025-11-21 15:45:35.344', '2025-11-21 15:45:35.344', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('2c4af531-696b-433f-8221-da444b1ae69a', '818f6d63-d26e-4e0f-be4f-c6e0f2fdd83a', 'Standard', 'SKU-1763739961565', 22, '2025-11-21 15:46:01.566', '2025-11-21 15:46:01.566', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('c5bf7174-4d90-47c7-8f72-0d1a1f53e65c', 'a74b4da5-e8e6-4b9a-9098-fc5ed8fcb96e', 'Standard', 'SKU-1763739980624', 50, '2025-11-21 15:46:20.625', '2025-11-21 15:46:20.625', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('08fb75e7-b5e2-4888-891a-c276a7e85bdc', 'f82f0d95-a58c-4fab-9093-d84d9d124e79', 'Standard', 'SKU-1763739997002', 8, '2025-11-21 15:46:37.003', '2025-11-21 15:46:37.003', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('41206c77-cc3b-4f28-908e-e42605153cdf', '9dd0fa49-eb8e-4825-bad8-5ee78829a648', 'Standard', 'SKU-1763740019772', 12, '2025-11-21 15:46:59.773', '2025-11-21 15:46:59.773', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('30de1cd6-b5c0-428b-93dc-9ccaeaf28702', '03618610-c935-458f-9b9d-0b2c559cc80a', 'Standard', 'SKU-1763740036353', 5, '2025-11-21 15:47:16.353', '2025-11-21 15:47:16.353', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('b137143b-250c-42e6-bc7c-7114a8bd7a51', 'eea6365c-631e-419d-b244-71b85af1ba08', 'Standard', 'SKU-1763740054732', 25, '2025-11-21 15:47:34.733', '2025-11-21 15:47:34.733', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('3040af8b-c379-4b9a-a9ab-df8c72c06012', '81f802fd-915e-4583-91b0-6aea6d8f8e6e', 'Standard', 'SKU-1763740071742', 7, '2025-11-21 15:47:51.743', '2025-11-21 15:47:51.743', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('41445f5c-0965-41b6-bca5-6fb37ee75a15', 'c4115347-1cc1-4695-a21a-3347260765e2', 'Standard', 'SKU-1763740092220', 1.55, '2025-11-21 15:48:12.221', '2025-11-21 15:48:12.221', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('fcc0f89e-1587-4a20-a760-b5e25f9723a7', '8b4caf63-8561-479b-bb85-f752c5bb7fa4', 'Standard', 'SKU-1763740106560', 12, '2025-11-21 15:48:26.561', '2025-11-21 15:48:26.561', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('b506472d-de6a-40b0-ba03-c3c4f3f75f1d', '49e65db3-8ff3-407a-94b6-eb309bc15601', 'Standard', 'SKU-1763740126914', 8, '2025-11-21 15:48:46.915', '2025-11-21 15:48:46.915', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d4e89b60-7af4-4428-9e84-119affa90155', 'a4da266d-cfc2-43d3-b0cf-9c99ae614658', 'Standard', 'SKU-1763740177015', 10, '2025-11-21 15:49:37.016', '2025-11-21 15:49:37.016', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('a666d35e-f9cb-4771-995c-e9758bb6f159', '07507429-9ce0-418a-a35d-7643ae5e87e3', 'Standard', 'SKU-1763740336801', 1, '2025-11-21 15:52:16.802', '2025-11-21 15:52:16.802', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d9fe6350-d7d0-4d92-9908-9756cbcd4eff', '78fd0a56-c2d8-40c3-98e1-c5719d4e6b8a', 'Standard', 'SKU-1763740407031', 45, '2025-11-21 15:53:27.032', '2025-11-21 15:53:27.032', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('cfe05d2e-ab78-4690-ab6d-249ab7e7418e', '3926b296-8a49-4069-af09-bceba9c05a6e', 'Standard', 'SKU-1763740465732', 10, '2025-11-21 15:54:25.733', '2025-11-21 15:54:25.733', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('4c3ff77f-598d-4a72-aa69-34942e4163f2', '0522b5b2-4d17-4799-93c4-cab090413a75', 'Standard', 'SKU-1763740509274', 10, '2025-11-21 15:55:09.276', '2025-11-21 15:55:09.276', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('4b08316f-d0f5-4bbf-9def-a615bd3c98b5', '47ad7e0f-443d-455a-97b7-486b67f4ffee', 'Standard', 'SKU-1763740653535', 8.5, '2025-11-21 15:57:33.536', '2025-11-21 15:57:33.536', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('975df487-0dd5-419d-a9c6-203e69dd2828', '0a330f42-289f-4aba-9593-3e018dcd63e3', 'Standard', 'SKU-1763740731487', 9, '2025-11-21 15:58:51.488', '2025-11-21 15:58:51.488', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('b40ad9d9-fa3b-4920-aad5-2a1e75ab4d7e', 'da521968-1a52-48cb-8c18-fb0c09d8c740', 'Standard', 'SKU-1763740770695', 1.5, '2025-11-21 15:59:30.696', '2025-11-21 15:59:30.696', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('9b6ed086-28c4-4776-8d9f-3628194dedd1', '49866da0-a628-419b-8c6b-fee62e994f12', 'Standard', 'SKU-1763740803791', 3.5, '2025-11-21 16:00:03.792', '2025-11-21 16:00:03.792', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('7b34838f-f75f-4c44-850a-06f1b5130ccb', 'd0c7165a-a9dd-444a-9a2c-670bb6e0d495', 'Standard', 'SKU-1763740852092', 8, '2025-11-21 16:00:52.092', '2025-11-21 16:00:52.092', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('51985e6d-ef5c-4de4-950b-791c5f264377', '859abf70-a058-4d64-be78-c7d6d949cb49', 'Standard', 'SKU-1763740882882', 12.5, '2025-11-21 16:01:22.883', '2025-11-21 16:01:22.883', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('bb45f1cd-a048-4c01-bf0d-30e183029ea3', '24e37877-6e6d-4235-8d99-f2eb74390aab', 'Standard', 'SKU-1763741384970', 30, '2025-11-21 16:09:44.971', '2025-11-21 16:09:44.971', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('3ecb2207-36d7-4b6d-bf82-8985a150fd03', '0923fa1a-d5c3-4230-b77f-7f8d6f857fc6', 'Standard', 'SKU-1763741509978', 22, '2025-11-21 16:11:49.979', '2025-11-21 16:11:49.979', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('9af9f865-d3dd-4ecc-91ba-78d7da227393', '4c06a459-3202-4f66-8c15-c2457dbbec1c', 'Standard', 'SKU-1763741657749', 11, '2025-11-21 16:14:17.75', '2025-11-21 16:14:17.75', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('e26807fc-008a-4928-9541-e8b4da9baf4b', '0f7f64f9-5145-4de9-a53c-f6498f4f64f1', 'Standard', 'SKU-1763741782508', 0.5, '2025-11-21 16:16:22.509', '2025-11-21 16:16:22.509', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('3b5291bf-f7ea-4a21-8d3e-0f953e80d9a2', '8f32cdcd-d59c-4961-9296-e840abe4e152', 'Standard', 'SKU-1763741896139', 5, '2025-11-21 16:18:16.14', '2025-11-21 16:18:16.14', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('54c115e0-f005-45ea-827d-e3a9ea4aebc7', '7cc4a1da-c026-496c-ab01-f7bf459a45ee', 'Standard', 'SKU-1763741986350', 1.133, '2025-11-21 16:19:46.351', '2025-11-21 16:19:46.351', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('dd1d28c3-30c4-47c4-927d-329dd8e28fb5', '94a63105-1709-4fcc-b943-b068deb0ab0b', 'Standard', 'SKU-1763742054117', 0.5, '2025-11-21 16:20:54.118', '2025-11-21 16:20:54.118', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('496de5f3-299c-409b-9222-1a0c3dfc1dda', 'aba5d0f5-1b5f-42c7-a215-47036b73f165', 'Standard', 'SKU-1763742150917', 5.5, '2025-11-21 16:22:30.918', '2025-11-21 16:22:30.918', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('1f22ef2a-749f-4c71-a949-e0808654566b', '4b501847-2e5c-45f6-90f9-aa68d25e5d9e', 'Standard', 'SKU-1763742200138', 9, '2025-11-21 16:23:20.139', '2025-11-21 16:23:20.139', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d25e3519-8aaa-4681-94f0-3c7707dc81a1', 'dd2c6f0f-9f32-4fb9-a80f-86e4140bd567', 'Standard', 'SKU-1763742310045', 66, '2025-11-21 16:25:10.045', '2025-11-21 16:25:10.045', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('25f6e022-79f3-4451-8f79-85a55e7d4a27', '0fcf8703-54de-41d6-a469-025ce9595c1f', 'Standard', 'SKU-1763742489266', 1.1666, '2025-11-21 16:28:09.266', '2025-11-21 16:28:09.266', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('c3201df2-1081-4b19-9c9c-74e096f16b40', 'becbce06-c32b-42d1-b249-f384d91015c3', 'Standard', 'SKU-1763742593604', 10, '2025-11-21 16:29:53.605', '2025-11-21 16:29:53.605', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('3082b783-988a-4194-b019-4a51b5f7bb0a', 'd1ace4ef-0b85-428b-864d-4117acaf11a9', 'Standard', 'SKU-1763742803364', 20, '2025-11-21 16:33:23.365', '2025-11-21 16:33:23.365', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('7c3d1693-7726-4316-94f7-db833c82ca90', 'f4ef2c9c-c2e7-428c-b09f-bf3063050838', 'Standard', 'SKU-1763742830824', 12, '2025-11-21 16:33:50.825', '2025-11-21 16:33:50.825', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('69a1f8b3-22d6-4afe-a8c2-a59bc8ef8fa5', '67eaef21-40a0-4d35-8ce3-fd9a492ea84d', 'Standard', 'SKU-1763742889962', 0.07, '2025-11-21 16:34:49.963', '2025-11-21 16:34:49.963', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('2f93c069-41fe-4cf4-9d96-5d6ddf914843', '7aade529-b89d-43cc-b0a7-bf3e46b3e2db', 'Standard', 'SKU-1763743046598', 5, '2025-11-21 16:37:26.599', '2025-11-21 16:37:26.599', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('528c7d03-043c-48d3-9936-7e7a8c1964e9', 'ef53799d-b9c4-4c05-bc2f-e87f17f8854e', 'Standard', 'SKU-1763743221625', 20, '2025-11-21 16:40:21.626', '2025-11-21 16:40:21.626', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('7aed27f9-8d03-4381-ad76-fbe20559ad33', '57be46a6-49c4-4f89-b061-c75492d01f0e', 'Standard', 'SKU-1763743274559', 30, '2025-11-21 16:41:14.56', '2025-11-21 16:41:14.56', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('424d8d10-bf75-4097-83b3-04cc8c3b91c9', '08392e21-22d2-4ed7-aaf1-8a75518f8ebe', 'Standard', 'SKU-1763743485788', 20, '2025-11-21 16:44:45.789', '2025-11-21 16:44:45.789', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('a6276221-ebd7-4298-86da-6cd2d243ec0d', 'a67be986-feec-4a94-b1ce-0f9784149f17', 'Standard', 'SKU-1763743594919', 10, '2025-11-21 16:46:34.92', '2025-11-21 16:46:34.92', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('3880f7a6-20c9-4f42-b82e-ab99b4389d27', '0a68bb1d-bfe1-4599-8e48-5e671f9147b3', 'Standard', 'SKU-1763743639564', 22, '2025-11-21 16:47:19.564', '2025-11-21 16:47:19.564', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('f9ddc938-0bca-4cd7-8b2a-4271b215811e', '8d35e1b0-8a6e-477b-8d0f-78b8aea029f9', 'Standard', 'SKU-1763743669644', 12, '2025-11-21 16:47:49.645', '2025-11-21 16:47:49.645', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('c02b4cee-d12a-4bcf-997e-966c020d26bb', '8ac65dac-c6a1-4d8b-b1dc-c8b37dad1150', 'Standard', 'SKU-1763743715142', 17, '2025-11-21 16:48:35.144', '2025-11-21 16:48:35.144', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('585e089e-fc7c-4ceb-9682-5f56c8266322', 'a0d4bdcd-3fe9-4766-ad3e-623a5ce9a0ad', 'Standard', 'SKU-1763743812112', 20, '2025-11-21 16:50:12.113', '2025-11-21 16:50:12.113', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('6bc333ea-0ba3-4f7b-986e-fb68d7bb777f', '8ceecb45-ab8f-429e-a632-92a36ee24ccb', 'Standard', 'SKU-1763743921578', 0.8, '2025-11-21 16:52:01.579', '2025-11-21 16:52:01.579', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('ae3f130a-aab6-45ed-8622-68cf89246ec2', '99f77cf8-fd07-4b24-be0b-f45f4ef0eae1', 'Standard', 'SKU-1763743989733', 17, '2025-11-21 16:53:09.733', '2025-11-21 16:53:09.733', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('52afb0c0-700c-4144-a587-46d9b9b437e6', '46646709-c8da-43af-a98c-775bc8e37758', 'Standard', 'SKU-1763744033028', 8, '2025-11-21 16:53:53.029', '2025-11-21 16:53:53.029', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('3e124afe-80d0-4324-931b-a1d10bf83f13', 'd1930eb3-7c68-4f43-9a2c-71ab0d491383', 'Standard', 'SKU-1763744101479', 12, '2025-11-21 16:55:01.48', '2025-11-21 16:55:01.48', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('06c213a6-344a-4582-84a7-c98bc8b5ead9', 'a5648fe4-7909-426e-9486-2e9d906fbd52', 'Standard', 'SKU-1763744173782', 7, '2025-11-21 16:56:13.784', '2025-11-21 16:56:13.784', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('4e5fca3a-e731-477d-821f-336a80a212f1', '8991d49e-8641-4b42-b2db-6418bbbcbea7', 'Standard', 'SKU-1763744217686', 22, '2025-11-21 16:56:57.687', '2025-11-21 16:56:57.687', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('3d0030c3-fd96-4c34-8cc2-bacda95a1cce', 'da5b976d-a8eb-4915-9fcd-b51849e9c5bf', 'Standard', 'SKU-1763744276989', 17.5, '2025-11-21 16:57:56.99', '2025-11-21 16:57:56.99', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('fe05e82b-0ded-4bd8-9344-5a7fdeb555b4', 'e3758e4e-cf22-4880-90bc-3a20a28f6b8b', 'Standard', 'SKU-1763744330457', 12, '2025-11-21 16:58:50.458', '2025-11-21 16:58:50.458', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d3b8f7a5-b716-49a6-93c0-cd95e9f04552', '6a9e818a-e208-487b-a873-4004b559810e', 'Standard', 'SKU-1763744375562', 12, '2025-11-21 16:59:35.563', '2025-11-21 16:59:35.563', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('541ae51c-6b9d-4a54-a706-fe48aecb61fd', 'a37d422e-0861-4c58-a9e2-59fe90a428c8', 'Standard', 'SKU-1763746991461', 1, '2025-11-21 17:43:11.462', '2025-11-21 17:43:11.462', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('e3f7c84a-03cb-4e97-84ef-5e7e4790ecc5', '95a15f89-08a9-4a96-9ef7-6d5a395842c9', 'Standard', 'SKU-1763747013864', 2, '2025-11-21 17:43:33.865', '2025-11-21 17:43:33.865', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('3f9f8c2e-ff8a-423e-8325-e780421553dd', 'd79bce7a-d94e-4669-9267-afa7add7ec8c', 'Standard', 'SKU-1763747051247', 2, '2025-11-21 17:44:11.248', '2025-11-21 17:44:11.248', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d6606dda-bf54-4c35-8b85-28e54281e40f', 'c3cc0e0a-aa56-4f14-9e93-93f412c395fb', 'Standard', 'SKU-1763747085969', 10, '2025-11-21 17:44:45.97', '2025-11-21 17:44:45.97', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('9059139f-a0a1-4b77-9570-dd71a046d150', '50675671-c41b-4d9d-bd1a-22b94dc2999d', 'Standard', 'SKU-1763747157689', 9, '2025-11-21 17:45:57.69', '2025-11-21 17:45:57.69', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('b660c68c-c11b-4e3f-bdf7-f7901ec78bd1', '43241a43-5b4a-4316-b170-c082079dc449', 'Standard', 'SKU-1763747243687', 8, '2025-11-21 17:47:23.688', '2025-11-21 17:47:23.688', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('a3df3443-a917-4e67-90d9-d980596cb5fd', '8f83f97f-7cdc-4118-adf8-5e87718a9296', 'Standard', 'SKU-1763747291514', 11, '2025-11-21 17:48:11.515', '2025-11-21 17:48:11.515', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('60f53811-0a66-4916-8018-169a0f5a186c', '82ec6ae7-e638-4228-b6a8-f57032acb350', 'Standard', 'SKU-1763747314978', 11, '2025-11-21 17:48:34.979', '2025-11-21 17:48:34.979', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('e2c2a40a-b481-4890-a7c4-8a56400c34af', '2a57c32e-d35f-4dfa-a1dc-fafe0cb77d1d', 'Standard', 'SKU-1763747534466', 6, '2025-11-21 17:52:14.467', '2025-11-21 17:52:14.467', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('a3716c40-0d7c-4613-a512-59c07054221d', '995c2f42-0d43-4c9a-9ee8-bc1924460928', 'Standard', 'SKU-1763747661982', 19, '2025-11-21 17:54:21.983', '2025-11-21 17:54:21.983', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('e32ff413-4f0f-4991-9397-354f60252315', '3caeb40c-6758-458b-be63-2e9c01d0c95b', 'Standard', 'SKU-1763747717227', 12, '2025-11-21 17:55:17.228', '2025-11-21 17:55:17.228', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('4b47e18b-af51-4cc8-abdb-b3e931aad102', '1f8c6530-10e7-4f66-8002-fe11ab3b272d', 'Standard', 'SKU-1763747860361', 19, '2025-11-21 17:57:40.361', '2025-11-21 17:57:40.361', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('60651f63-f6d2-4a4e-a1b4-0a1229158eca', '7a7c3bb8-d91f-4c09-8f86-c8d1abdca469', 'Standard', 'SKU-1763747886725', 12, '2025-11-21 17:58:06.726', '2025-11-21 17:58:06.726', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('a5dca170-c11b-4d3c-bf1b-9ca8d79d14f6', '1b33594b-cef3-4b49-a8f7-3c569a43d5c9', 'Standard', 'SKU-1763748048529', 3.5, '2025-11-21 18:00:48.53', '2025-11-21 18:00:48.53', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('9e5e39e3-58e2-48ab-9476-3e17a952a3c1', 'cc9c04eb-5d29-4d9e-8956-ce0fbd54c12d', 'Standard', 'SKU-1763748076396', 12, '2025-11-21 18:01:16.396', '2025-11-21 18:01:16.396', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('b809e61e-e4c5-4bd7-ab36-dd1208db38ce', '641c7585-710a-4b9e-8022-dcbd8e1d8f85', 'Standard', 'SKU-1763748139394', 6, '2025-11-21 18:02:19.395', '2025-11-21 18:02:19.395', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d9f7f0df-5fae-49a6-b388-3dc95d6c3616', '13c70993-3259-4f8c-80f2-24a98b35e457', 'Standard', 'SKU-1763748202908', 16, '2025-11-21 18:03:22.909', '2025-11-21 18:03:22.909', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('bee2a558-7c70-4e43-89eb-ef6eac27739f', '514a036d-e31e-47ec-84de-cfcf604dfa60', 'Standard', 'SKU-1763748266125', 7, '2025-11-21 18:04:26.126', '2025-11-21 18:04:26.126', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('ab26e9c9-c39f-420c-883f-f158af445b38', 'a31b5045-9020-4585-936a-694b392bdea8', 'Standard', 'SKU-1763748289892', 13, '2025-11-21 18:04:49.893', '2025-11-21 18:04:49.893', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('0b7cecf5-7389-441d-b9f2-50e9ac194c82', '6debfa75-fac4-4c0d-9df9-31297fda8370', 'Standard', 'SKU-1763748373959', 9, '2025-11-21 18:06:13.96', '2025-11-21 18:06:13.96', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('8ebc8034-4965-460f-a6bf-a96017c5f03a', '2623e13c-2002-4898-99a2-0b4fc49a4ee9', 'Standard', 'SKU-1763748395558', 4, '2025-11-21 18:06:35.558', '2025-11-21 18:06:35.558', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('fcad7251-8610-4938-ae5c-47e50dcb0b37', '2c083ed5-5de6-4f00-a64a-47ae8d399fec', 'Standard', 'SKU-1763748421442', 6, '2025-11-21 18:07:01.442', '2025-11-21 18:07:01.442', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('99a4023b-91e2-4275-ae1e-8df4296adaa4', '2b4c62e7-3fb9-4b97-864d-36d73b7f7aeb', 'Standard', 'SKU-1763748440919', 6, '2025-11-21 18:07:20.92', '2025-11-21 18:07:20.92', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('2e64bece-1f47-48de-8097-0fb0ed261b14', 'f76658c9-a5db-45c5-ba74-1512824734ea', 'Standard', 'SKU-1763748466318', 16, '2025-11-21 18:07:46.319', '2025-11-21 18:07:46.319', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('a09ab0a6-2432-41cb-aaee-5fd8af20f8f7', 'f6fd2a29-c047-4ee0-a7c1-1381943fbe2d', 'Standard', 'SKU-1763748583966', 8, '2025-11-21 18:09:43.967', '2025-11-21 18:09:43.967', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('ddfdc607-0dcd-41ca-bab5-2002ee92715c', 'fa55b2c4-112d-41b8-adb2-f5e632192f47', 'Standard', 'SKU-1763749010180', 25, '2025-11-21 18:16:50.181', '2025-11-21 18:16:50.181', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('5c4740b5-207a-46f0-b7b5-d04d2436d8a8', 'd899aa82-7ef2-40c4-bcb0-3bd18efb8e28', 'Standard', 'SKU-1763749049483', 5, '2025-11-21 18:17:29.484', '2025-11-21 18:17:29.484', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('ce3843a6-f8ba-4ae7-9eeb-026249e1ac91', '1808c1f1-8f20-45a2-b397-7fccbabb0969', 'Standard', 'SKU-1763750768352', 12, '2025-11-21 18:46:08.353', '2025-11-21 18:46:08.353', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('384b44db-c9e3-4de9-b994-bde0d972443f', '3115916c-2e5c-4e88-a06b-793c227d13f3', 'Standard', 'SKU-1763750977479', 8, '2025-11-21 18:49:37.48', '2025-11-21 18:49:37.48', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('a9f086b6-d7ae-48e6-a554-451992bb079a', 'd50643f2-ab61-4cae-9836-067fa8a59ae2', 'Standard', 'SKU-1763751129883', 12, '2025-11-21 18:52:09.884', '2025-11-21 18:52:09.884', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('01cc0e69-718a-4c6d-8ee9-d855a0148642', 'da93723a-ac51-4986-8c8c-e0703bbf33d3', 'Standard', 'SKU-1763751251380', 50, '2025-11-21 18:54:11.382', '2025-11-21 18:54:11.382', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('cfd5b1d5-106f-472c-853f-683943afdca6', '921082f6-c9ad-4588-b950-dc31b6b7c25c', 'Standard', 'SKU-1763751820307', 12, '2025-11-21 19:03:40.308', '2025-11-21 19:03:40.308', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('6e865177-c4e8-4b50-8e40-ef563eeb6f67', '84f3a7da-379e-472d-ae38-166ea9d71d09', 'Standard', 'SKU-1763751986485', 30, '2025-11-21 19:06:26.486', '2025-11-21 19:06:26.486', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('a5e7ba1f-0657-4545-8576-63b9427d3f46', 'c7a857de-5634-4eff-93c6-7bb3ada5e735', 'Standard', 'SKU-1763752095274', 2.5, '2025-11-21 19:08:15.274', '2025-11-21 19:08:15.274', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d7e77ab9-7ae9-47ef-b72c-9d53ef0f2711', '2e8b85b0-f8d1-4904-bcc6-352baa971d50', 'Standard', 'SKU-1763762792425', 10, '2025-11-21 22:06:32.427', '2025-11-21 22:06:32.427', 'bbfe6914-675b-4dd6-a172-d1c637e75e27');
INSERT INTO public.product_variants VALUES ('a16f14ce-1b2e-4555-99b1-c1b8428a645d', '68506d29-84fb-406d-9c65-31d8b77c971d', 'Standard', 'SKU-1763762802223', 10, '2025-11-21 22:06:42.224', '2025-11-21 22:06:42.224', 'bbfe6914-675b-4dd6-a172-d1c637e75e27');
INSERT INTO public.product_variants VALUES ('caac663b-1c7b-4e68-b37d-e903ca1b3cfa', '87f83da4-b214-4549-97fb-79c04f818040', 'Standard', 'SKU-1763790454495', 45, '2025-11-22 05:47:34.495', '2025-11-22 05:47:34.495', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('4c5e82d0-c2a4-485f-a176-8af57ee4b910', '0332bae2-8703-446f-b60c-0c6777407665', 'Standard', 'SKU-1763790738169', 650, '2025-11-22 05:52:18.17', '2025-11-22 05:52:18.17', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('b0b45df6-6a81-4d4d-b11d-4d4895f947fc', 'b9e46bf2-9a4a-4944-9406-ba1e58fd504f', 'Standard', 'SKU-1763790787190', 650, '2025-11-22 05:53:07.19', '2025-11-22 05:53:07.19', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('28fba87b-5fbd-40d6-a1e5-f0a308020617', '708a2bbc-6567-4035-a321-270e8b403c96', 'Standard', 'SKU-1763790820464', 650, '2025-11-22 05:53:40.466', '2025-11-22 05:53:40.466', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d34dd1da-58c9-4ea9-a062-39c3d6e86c35', '730357ee-3895-41fb-ad4e-bd9f72456ea6', 'Standard', 'SKU-1763790852722', 650, '2025-11-22 05:54:12.723', '2025-11-22 05:54:12.723', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('03c2981f-dbc1-4bb0-bc38-d8269a54959f', '6eb70b5a-e68d-437d-9da4-0a65fc156451', 'Standard', 'SKU-1763790890961', 650, '2025-11-22 05:54:50.962', '2025-11-22 05:54:50.962', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('154fda53-e8dc-47e6-b386-c7068e6980ba', '6a6f9e64-abd9-423d-acf1-d7bdce5e8863', 'Standard', 'SKU-1763791806822', 100, '2025-11-22 06:10:06.823', '2025-11-22 06:10:06.823', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d954d3a4-94b8-48ee-b60f-5244a26da1ba', 'd836af77-e08d-4e73-9c0b-52f1b0e5aae2', 'Standard', 'SKU-1763791873583', 100, '2025-11-22 06:11:13.584', '2025-11-22 06:11:13.584', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('8ace8549-c2f8-4327-9e83-84cf7c98ced3', 'c32a0939-b4cb-4de8-8a9f-f7642cfa08cb', 'Standard', 'SKU-1763791885723', 100, '2025-11-22 06:11:25.724', '2025-11-22 06:11:25.724', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('ee9e1eb8-e461-4fdc-9331-a75d84f3afaa', '44ff3552-490e-45b8-9430-0219f75f2378', 'Standard', 'SKU-1763791901900', 100, '2025-11-22 06:11:41.901', '2025-11-22 06:11:41.901', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('21999888-0244-4e73-b704-bc917c14a773', '11ff3481-7d74-4e50-99d4-490dd82020b8', 'Standard', 'SKU-1763791908913', 100, '2025-11-22 06:11:48.914', '2025-11-22 06:11:48.914', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('be6899f1-6147-4c08-ac0f-96fe7dc2adb7', '0d6f338c-abf1-4d53-a8ef-1965aed42a52', 'Standard', 'SKU-1763792365238', 200, '2025-11-22 06:19:25.239', '2025-11-22 06:19:25.239', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('c9c02659-64c1-4c2c-aea8-db974d2e053c', '0f47c960-7f46-47ea-8359-48cfa491482c', 'Standard', 'SKU-1763792379187', 120, '2025-11-22 06:19:39.188', '2025-11-22 06:19:39.188', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('f9b8e7ad-520e-4b4a-9da6-76fea46a375d', '310114a9-fe38-460c-a8c1-a7ef6a6dbbf8', 'Standard', 'SKU-1763792440828', 100, '2025-11-22 06:20:40.829', '2025-11-22 06:20:40.829', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('68751ddc-272d-48c5-b5be-e618482ea722', 'b9f16a97-bffd-4fad-bb17-6a2dac295586', 'Standard', 'SKU-1763792487547', 100, '2025-11-22 06:21:27.548', '2025-11-22 06:21:27.548', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('b364871b-e1cf-4a04-9b33-574240454aeb', 'c13ac820-1fda-4181-bfda-1ae720b0d85a', 'Standard', 'SKU-1763792529755', 100, '2025-11-22 06:22:09.756', '2025-11-22 06:22:09.756', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('ecc3d6e7-115d-4f24-b58b-7c7cb9a21989', '2445b723-f796-42ef-a65d-2f38afd2483b', 'Standard', 'SKU-1763792536682', 100, '2025-11-22 06:22:16.683', '2025-11-22 06:22:16.683', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('dd2c05d7-3b63-45c6-8ea0-f55afc3f9cdf', 'c541a6e8-2365-4fc6-bdd7-59b296e6537b', 'Standard', 'SKU-1763792546835', 100, '2025-11-22 06:22:26.836', '2025-11-22 06:22:26.836', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('fe7d0e80-b0c7-4fc6-8b41-9aa9649e73e0', 'bf926a2a-cd04-42f4-886d-1cbb22e2ded5', 'Standard', 'SKU-1763792912609', 105, '2025-11-22 06:28:32.609', '2025-11-22 06:28:32.609', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('e6fa8446-c578-42b4-88f4-5b3f55a62398', 'f32a74fb-8dba-41d6-9648-462517b46c67', 'Standard', 'SKU-1763793440709', 22, '2025-11-22 06:37:20.71', '2025-11-22 06:37:20.71', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('b32327d9-0710-44fa-872d-f223f27d4654', '0c9f6566-292b-42c0-8a5e-733aa58062ee', 'Standard', 'SKU-1763793494235', 5, '2025-11-22 06:38:14.236', '2025-11-22 06:38:14.236', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('17386eda-fbd7-4e2a-961e-2f0c702e68bb', '407252ff-9b1a-4062-8584-fc1352329fcc', 'Standard', 'SKU-1763793558984', 11, '2025-11-22 06:39:18.985', '2025-11-22 06:39:18.985', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('99a5297c-7395-4828-bf8f-1a9692ced565', '4d69c874-f87a-4cc9-980e-b17edd3dcfcb', 'Standard', 'SKU-1763793616222', 8, '2025-11-22 06:40:16.224', '2025-11-22 06:40:16.224', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('3213ccd8-c615-4ec1-a848-a1830613ac2b', 'fc317a9e-af62-4014-81af-066450c3ca9c', 'Standard', 'SKU-1763793863839', 7, '2025-11-22 06:44:23.84', '2025-11-22 06:44:23.84', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('682acf5e-73f9-4592-9034-cc4a06271e22', '43a204f8-2a67-4ff8-ae51-8ff2c23d6807', 'Standard', 'SKU-1763793889508', 50, '2025-11-22 06:44:49.51', '2025-11-22 06:44:49.51', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('915208c4-e2dd-43c3-b978-4e741693f230', '1fe723fa-4041-4929-b8dc-a054e75398d3', 'Standard', 'SKU-1763793940498', 55, '2025-11-22 06:45:40.499', '2025-11-22 06:45:40.499', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('e198da08-0b40-4eed-a46e-6aeb229a68c3', 'e5571aa9-36f2-4573-b5a8-23ed4ce1544c', 'Standard', 'SKU-1763793962945', 0.5, '2025-11-22 06:46:02.946', '2025-11-22 06:46:02.946', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('381ccef3-af4d-4d1c-8c1a-b687a771f79b', 'faf75c40-315b-476c-b8cd-ab5f95c20bf3', 'Standard', 'SKU-1763793999986', 30, '2025-11-22 06:46:39.987', '2025-11-22 06:46:39.987', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('d76cfce6-68b1-4059-a6d2-112573e5781f', '6499f1fe-4fa6-4836-b823-00d43ddd6312', 'Standard', 'SKU-1763794137887', 40, '2025-11-22 06:48:57.888', '2025-11-22 06:48:57.888', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('c1f64388-de12-46fe-aa9c-b0fe32d31d9f', 'ace87ab7-3a9f-46bb-b8c7-9432ca953a07', 'Standard', 'SKU-1763794028075', 4.5, '2025-11-22 06:47:08.076', '2025-11-22 06:47:08.076', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('62345a9d-9890-4c88-ad7b-5e8df9199e45', '7163051d-f6ba-4dc1-bf52-7feaa38dfd5c', 'Standard', 'SKU-1763794091270', 2, '2025-11-22 06:48:11.271', '2025-11-22 06:48:11.271', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('18654532-9989-4840-8edb-7569d2da913c', 'a924f483-484e-4187-b076-c50203962368', 'Standard', 'SKU-1763794136994', 5, '2025-11-22 06:48:56.995', '2025-11-22 06:48:56.995', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('553fc8e7-f279-4aac-8076-8bee1f8e4748', 'f83be26b-174f-4fb5-8111-6da3bb2f2d5b', 'Standard', 'SKU-1763794196765', 70, '2025-11-22 06:49:56.766', '2025-11-22 06:49:56.766', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('6311f89e-677a-448a-bd47-ee29ee893c33', 'de9558a7-d6b4-46c3-9883-c4cd16c2974a', 'Standard', 'SKU-1763794264326', 55, '2025-11-22 06:51:04.327', '2025-11-22 06:51:04.327', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('8c4af296-8d8c-4723-b5e0-46f2bccd25f8', 'fda85ff1-80d0-4118-97b0-455062708999', 'Standard', 'SKU-1763794322075', 11, '2025-11-22 06:52:02.076', '2025-11-22 06:52:02.076', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('f4915819-0eda-4e11-9b19-57c70495351c', '8e31e5c2-5bf8-4ff6-8c6a-44f92667e68d', 'Standard', 'SKU-1763794343349', 90, '2025-11-22 06:52:23.35', '2025-11-22 06:52:23.35', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('e781ed6b-0aaa-47c0-ac6e-42eecae2405c', '411813fc-00bf-407b-87de-7f6da62a9d5c', 'Standard', 'SKU-1763794380986', 200, '2025-11-22 06:53:00.987', '2025-11-22 06:53:00.987', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('c8e7f48c-6d1d-460a-8627-85804d568bdd', '0c8910b6-d676-4e26-ae83-e6f19ef773d1', 'Standard', 'SKU-1763794407907', 250, '2025-11-22 06:53:27.908', '2025-11-22 06:53:27.908', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('b06f98f2-83aa-4df1-91be-edb58d0f3bff', '5da1ddc7-ad56-4992-b104-1d13340e0f16', 'Standard', 'SKU-1763794432878', 45, '2025-11-22 06:53:52.879', '2025-11-22 06:53:52.879', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('73bb0068-dc01-4f3d-b189-66efdac73dfa', 'aaad4172-6f6b-44cf-8e5a-916e96bc9afa', 'Standard', 'SKU-1763794481834', 125, '2025-11-22 06:54:41.836', '2025-11-22 06:54:41.836', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('4a34cdc9-0c04-43ea-b560-1b8425551c20', '781d6cb1-1e1f-435a-96bc-8653f0821e5b', 'Standard', 'SKU-1763794504813', 160, '2025-11-22 06:55:04.814', '2025-11-22 06:55:04.814', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.product_variants VALUES ('c504fefa-0316-4ed5-9134-af3e2fe95c54', '9de48886-54b8-4731-9df5-d737ffbf67d4', 'Standard', 'SKU-1763794563431', 100, '2025-11-22 06:56:03.432', '2025-11-22 06:56:03.432', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.products VALUES ('bd297b26-ed60-475b-b9c0-6279392cff39', 'baby lotion', NULL, NULL, NULL, '2025-11-21 12:50:33.177', '2025-11-21 12:50:33.177', NULL, NULL, 'GENERAL', '2e0136a8-d74a-408d-b8b6-7656732387d4');
INSERT INTO public.products VALUES ('c6e79076-6d3b-490f-b251-5fdf92d9f6e1', 'Flacol', NULL, NULL, NULL, '2025-11-21 15:32:26.063', '2025-11-21 15:32:26.063', 'Simethicone USP', 'Square', 'MEDICINE', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('7d6c27cb-0845-42ec-8e8f-0e643837ac83', 'Tetrasol', NULL, NULL, NULL, '2025-11-21 15:33:03.47', '2025-11-21 15:33:03.47', 'Monosulfiram BP 25%', 'ACI', 'MEDICINE', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('726faf10-b8a7-4424-b947-09e20cfd017f', 'Calamilon', NULL, NULL, NULL, '2025-11-21 15:34:19.922', '2025-11-21 15:34:19.922', 'Calamine', 'United Chemicals', 'MEDICINE', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('5719086a-4782-4f2e-a853-dae11df9587a', 'Linatab E 5/10 Tab', NULL, NULL, NULL, '2025-11-21 15:45:00.158', '2025-11-21 15:45:00.158', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('8449e4a8-0bb1-4721-8051-2075b98fe9ed', 'Camlosart 5/20  Tab', NULL, NULL, NULL, '2025-11-21 15:45:35.341', '2025-11-21 15:45:35.341', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('818f6d63-d26e-4e0f-be4f-c6e0f2fdd83a', 'Nidocarol Retard Tab', NULL, NULL, NULL, '2025-11-21 15:46:01.561', '2025-11-21 15:46:01.561', NULL, '', 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('a74b4da5-e8e6-4b9a-9098-fc5ed8fcb96e', 'Empaglif 25gm Tab', NULL, NULL, NULL, '2025-11-21 15:46:20.621', '2025-11-21 15:46:20.621', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('f82f0d95-a58c-4fab-9093-d84d9d124e79', 'Rivo 0.5mg', NULL, NULL, NULL, '2025-11-21 15:46:36.998', '2025-11-21 15:46:36.998', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('9dd0fa49-eb8e-4825-bad8-5ee78829a648', 'Lopirel 75mg Tab', NULL, NULL, NULL, '2025-11-21 15:46:59.769', '2025-11-21 15:46:59.769', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('03618610-c935-458f-9b9d-0b2c559cc80a', 'Larcadip 10mg Tab', NULL, NULL, NULL, '2025-11-21 15:47:16.35', '2025-11-21 15:47:16.35', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('eea6365c-631e-419d-b244-71b85af1ba08', 'Emayid 10mg Tab', NULL, NULL, NULL, '2025-11-21 15:47:34.73', '2025-11-21 15:47:34.73', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('81f802fd-915e-4583-91b0-6aea6d8f8e6e', 'Rostil 135mg Tab', NULL, NULL, NULL, '2025-11-21 15:47:51.739', '2025-11-21 15:47:51.739', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('c4115347-1cc1-4695-a21a-3347260765e2', 'Betaloc 25mg Tab', NULL, NULL, NULL, '2025-11-21 15:48:12.217', '2025-11-21 15:48:12.217', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('8b4caf63-8561-479b-bb85-f752c5bb7fa4', 'Rolip 5mg Tab', NULL, NULL, NULL, '2025-11-21 15:48:26.557', '2025-11-21 15:48:26.557', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('49e65db3-8ff3-407a-94b6-eb309bc15601', 'Tenocab 50mg', NULL, NULL, NULL, '2025-11-21 15:48:46.911', '2025-11-21 15:48:46.911', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('a4da266d-cfc2-43d3-b0cf-9c99ae614658', 'Angilock Plus 12.5mg Tab', NULL, NULL, NULL, '2025-11-21 15:49:37.009', '2025-11-21 15:49:37.009', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('07507429-9ce0-418a-a35d-7643ae5e87e3', 'Tenoloc 50mg Tab', NULL, NULL, NULL, '2025-11-21 15:52:16.797', '2025-11-21 15:52:16.797', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('78fd0a56-c2d8-40c3-98e1-c5719d4e6b8a', 'Sabitar 50mg Tab', NULL, NULL, NULL, '2025-11-21 15:53:27.029', '2025-11-21 15:53:27.029', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('3926b296-8a49-4069-af09-bceba9c05a6e', 'Osartil 50mg Tab', NULL, NULL, NULL, '2025-11-21 15:54:25.729', '2025-11-21 15:54:25.729', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0522b5b2-4d17-4799-93c4-cab090413a75', 'Osartil 50 Plus', NULL, NULL, NULL, '2025-11-21 15:55:09.269', '2025-11-21 15:55:09.269', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('47ad7e0f-443d-455a-97b7-486b67f4ffee', 'Amdocal Plus 50mg', NULL, NULL, NULL, '2025-11-21 15:57:33.532', '2025-11-21 15:57:33.532', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0a330f42-289f-4aba-9593-3e018dcd63e3', 'Frulac-20 Tab', NULL, NULL, NULL, '2025-11-21 15:58:51.484', '2025-11-21 15:58:51.484', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('da521968-1a52-48cb-8c18-fb0c09d8c740', 'Lasix 40mg Tab', NULL, NULL, NULL, '2025-11-21 15:59:30.693', '2025-11-21 15:59:30.693', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('49866da0-a628-419b-8c6b-fee62e994f12', 'Zolium 0.5mg Tab', NULL, NULL, NULL, '2025-11-21 16:00:03.788', '2025-11-21 16:00:03.788', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('d0c7165a-a9dd-444a-9a2c-670bb6e0d495', 'Disopan 0.5mg Tab', NULL, NULL, NULL, '2025-11-21 16:00:52.087', '2025-11-21 16:00:52.087', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('859abf70-a058-4d64-be78-c7d6d949cb49', 'Disopan 2mg Tab', NULL, NULL, NULL, '2025-11-21 16:01:22.878', '2025-11-21 16:01:22.878', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('24e37877-6e6d-4235-8d99-f2eb74390aab', 'Linatab E 10mg Tab', NULL, NULL, NULL, '2025-11-21 16:09:44.966', '2025-11-21 16:09:44.966', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0923fa1a-d5c3-4230-b77f-7f8d6f857fc6', 'Carlina 5mg Tab', NULL, NULL, NULL, '2025-11-21 16:11:49.975', '2025-11-21 16:11:49.975', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('4c06a459-3202-4f66-8c15-c2457dbbec1c', 'Cardobis Plus 5/6.25 Tab', NULL, NULL, NULL, '2025-11-21 16:14:17.745', '2025-11-21 16:14:17.745', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0f7f64f9-5145-4de9-a53c-f6498f4f64f1', 'Riboflavin', NULL, NULL, NULL, '2025-11-21 16:16:22.506', '2025-11-21 16:16:22.506', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('8f32cdcd-d59c-4961-9296-e840abe4e152', 'Ramoril 2.5mg', NULL, NULL, NULL, '2025-11-21 16:18:16.137', '2025-11-21 16:18:16.137', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('7cc4a1da-c026-496c-ab01-f7bf459a45ee', 'Thyrin 25mcg Tab', NULL, NULL, NULL, '2025-11-21 16:19:46.346', '2025-11-21 16:19:46.346', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('94a63105-1709-4fcc-b943-b068deb0ab0b', 'Riboson 5mg Tab', NULL, NULL, NULL, '2025-11-21 16:20:54.115', '2025-11-21 16:20:54.115', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('aba5d0f5-1b5f-42c7-a215-47036b73f165', 'Amdocal 5mg Tab', NULL, NULL, NULL, '2025-11-21 16:22:30.914', '2025-11-21 16:22:30.914', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('4b501847-2e5c-45f6-90f9-aa68d25e5d9e', 'Telmipres 40mg Tab', NULL, NULL, NULL, '2025-11-21 16:23:20.135', '2025-11-21 16:23:20.135', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('dd2c6f0f-9f32-4fb9-a80f-86e4140bd567', 'Thyrox 50mg Tab', NULL, NULL, NULL, '2025-11-21 16:25:10.041', '2025-11-21 16:25:10.041', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0fcf8703-54de-41d6-a469-025ce9595c1f', 'Thyrox 25mg Tab', NULL, NULL, NULL, '2025-11-21 16:28:09.263', '2025-11-21 16:28:09.263', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('becbce06-c32b-42d1-b249-f384d91015c3', 'Angilock Plus 50/12.5', NULL, NULL, NULL, '2025-11-21 16:29:53.599', '2025-11-21 16:29:53.599', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('d1ace4ef-0b85-428b-864d-4117acaf11a9', 'Prasurel 10mg Tab', NULL, NULL, NULL, '2025-11-21 16:33:23.362', '2025-11-21 16:33:23.362', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('f4ef2c9c-c2e7-428c-b09f-bf3063050838', 'Prasurel 5mg Tab', NULL, NULL, NULL, '2025-11-21 16:33:50.819', '2025-11-21 16:33:50.819', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('67eaef21-40a0-4d35-8ce3-fd9a492ea84d', 'Nidipine SR-20 Tab', NULL, NULL, NULL, '2025-11-21 16:34:49.96', '2025-11-21 16:34:49.96', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('7aade529-b89d-43cc-b0a7-bf3e46b3e2db', 'ATV 10mg Tab', NULL, NULL, NULL, '2025-11-21 16:37:26.594', '2025-11-21 16:37:26.594', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('ef53799d-b9c4-4c05-bc2f-e87f17f8854e', 'Creston 10mg Tab', NULL, NULL, NULL, '2025-11-21 16:40:21.613', '2025-11-21 16:40:21.613', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('57be46a6-49c4-4f89-b061-c75492d01f0e', 'Rosu 20mg Tab', NULL, NULL, NULL, '2025-11-21 16:41:14.556', '2025-11-21 16:41:14.556', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('08392e21-22d2-4ed7-aaf1-8a75518f8ebe', 'Paloxi Tab', NULL, NULL, NULL, '2025-11-21 16:44:45.785', '2025-11-21 16:44:45.785', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('a67be986-feec-4a94-b1ce-0f9784149f17', 'Rovast 5mg Tab', NULL, NULL, NULL, '2025-11-21 16:46:34.915', '2025-11-21 16:46:34.915', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0a68bb1d-bfe1-4599-8e48-5e671f9147b3', 'Rosuva 10mg Tab', NULL, NULL, NULL, '2025-11-21 16:47:19.562', '2025-11-21 16:47:19.562', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('8d35e1b0-8a6e-477b-8d0f-78b8aea029f9', 'Atova 10mg Tab', NULL, NULL, NULL, '2025-11-21 16:47:49.641', '2025-11-21 16:47:49.641', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('8ac65dac-c6a1-4d8b-b1dc-c8b37dad1150', 'Monas 10mg Tab', NULL, NULL, NULL, '2025-11-21 16:48:35.139', '2025-11-21 16:48:35.139', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('a0d4bdcd-3fe9-4766-ad3e-623a5ce9a0ad', 'Atova 20mg Tab', NULL, NULL, NULL, '2025-11-21 16:50:12.11', '2025-11-21 16:50:12.11', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('8ceecb45-ab8f-429e-a632-92a36ee24ccb', 'Ecosprin 75mg Tab', NULL, NULL, NULL, '2025-11-21 16:52:01.574', '2025-11-21 16:52:01.574', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('99f77cf8-fd07-4b24-be0b-f45f4ef0eae1', 'Montene 10mg Tab', NULL, NULL, NULL, '2025-11-21 16:53:09.728', '2025-11-21 16:53:09.728', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('46646709-c8da-43af-a98c-775bc8e37758', 'Hemorif Tab', NULL, NULL, NULL, '2025-11-21 16:53:53.026', '2025-11-21 16:53:53.026', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('d1930eb3-7c68-4f43-9a2c-71ab0d491383', 'Anclog Plus 75mg Tab', NULL, NULL, NULL, '2025-11-21 16:55:01.477', '2025-11-21 16:55:01.477', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('a5648fe4-7909-426e-9486-2e9d906fbd52', 'Montene 4mg', NULL, NULL, NULL, '2025-11-21 16:56:13.778', '2025-11-21 16:56:13.778', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('8991d49e-8641-4b42-b2db-6418bbbcbea7', 'Diamicron MR 60mg Tab', NULL, NULL, NULL, '2025-11-21 16:56:57.684', '2025-11-21 16:56:57.684', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('da5b976d-a8eb-4915-9fcd-b51849e9c5bf', 'Arovent 10mg', NULL, NULL, NULL, '2025-11-21 16:57:56.985', '2025-11-21 16:57:56.985', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('e3758e4e-cf22-4880-90bc-3a20a28f6b8b', 'Odrel Plug 75mg', NULL, NULL, NULL, '2025-11-21 16:58:50.452', '2025-11-21 16:58:50.452', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('6a9e818a-e208-487b-a873-4004b559810e', 'Lumona 10mg Tab', NULL, NULL, NULL, '2025-11-21 16:59:35.559', '2025-11-21 16:59:35.559', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('a37d422e-0861-4c58-a9e2-59fe90a428c8', 'Imotil 2mg Tab', NULL, NULL, NULL, '2025-11-21 17:43:11.458', '2025-11-21 17:43:11.458', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('95a15f89-08a9-4a96-9ef7-6d5a395842c9', 'Flagyl 400mg Tab', NULL, NULL, NULL, '2025-11-21 17:43:33.862', '2025-11-21 17:43:33.862', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('d79bce7a-d94e-4669-9267-afa7add7ec8c', 'Filmet 400mg Tab', NULL, NULL, NULL, '2025-11-21 17:44:11.242', '2025-11-21 17:44:11.242', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('c3cc0e0a-aa56-4f14-9e93-93f412c395fb', 'Linax Plus 2.5/850 Tab', NULL, NULL, NULL, '2025-11-21 17:44:45.968', '2025-11-21 17:44:45.968', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('50675671-c41b-4d9d-bd1a-22b94dc2999d', 'Linax Plus 2.5/500 Tab', NULL, NULL, NULL, '2025-11-21 17:45:57.687', '2025-11-21 17:45:57.687', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('43241a43-5b4a-4316-b170-c082079dc449', 'Calbo-D Tab', NULL, NULL, NULL, '2025-11-21 17:47:23.683', '2025-11-21 17:47:23.683', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('8f83f97f-7cdc-4118-adf8-5e87718a9296', 'Calboral-D Tab', NULL, NULL, NULL, '2025-11-21 17:48:11.511', '2025-11-21 17:48:11.511', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('82ec6ae7-e638-4228-b6a8-f57032acb350', 'G-Calbo Tab', NULL, NULL, NULL, '2025-11-21 17:48:34.976', '2025-11-21 17:48:34.976', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('2a57c32e-d35f-4dfa-a1dc-fafe0cb77d1d', 'Calboplex Tab', NULL, NULL, NULL, '2025-11-21 17:52:14.463', '2025-11-21 17:52:14.463', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('995c2f42-0d43-4c9a-9ee8-bc1924460928', 'Dialiptin-M 850mg', NULL, NULL, NULL, '2025-11-21 17:54:21.979', '2025-11-21 17:54:21.979', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('3caeb40c-6758-458b-be63-2e9c01d0c95b', 'Filwel Silver A to Z Tab', NULL, NULL, NULL, '2025-11-21 17:55:17.225', '2025-11-21 17:55:17.225', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('1f8c6530-10e7-4f66-8002-fe11ab3b272d', 'Vildapin Plus 500mg Tab', NULL, NULL, NULL, '2025-11-21 17:57:40.358', '2025-11-21 17:57:40.358', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('7a7c3bb8-d91f-4c09-8f86-c8d1abdca469', 'Filwel Gold A to Z Tab', NULL, NULL, NULL, '2025-11-21 17:58:06.723', '2025-11-21 17:58:06.723', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('1b33594b-cef3-4b49-a8f7-3c569a43d5c9', 'Xinc B Tab', NULL, NULL, NULL, '2025-11-21 18:00:48.527', '2025-11-21 18:00:48.527', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('cc9c04eb-5d29-4d9e-8956-ce0fbd54c12d', 'Uromax 0.4mg Tab', NULL, NULL, NULL, '2025-11-21 18:01:16.392', '2025-11-21 18:01:16.392', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('641c7585-710a-4b9e-8022-dcbd8e1d8f85', 'Glucomin 850mg Tab', NULL, NULL, NULL, '2025-11-21 18:02:19.392', '2025-11-21 18:02:19.392', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('13c70993-3259-4f8c-80f2-24a98b35e457', 'Calboral-DX Tab', NULL, NULL, NULL, '2025-11-21 18:03:22.906', '2025-11-21 18:03:22.906', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('514a036d-e31e-47ec-84de-cfcf604dfa60', 'Metfo XR 500mg Tab', NULL, NULL, NULL, '2025-11-21 18:04:26.123', '2025-11-21 18:04:26.123', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('a31b5045-9020-4585-936a-694b392bdea8', 'Calbotol Tab', NULL, NULL, NULL, '2025-11-21 18:04:49.889', '2025-11-21 18:04:49.889', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('6debfa75-fac4-4c0d-9df9-31297fda8370', 'Nitrocontin 6.4mg Tab', NULL, NULL, NULL, '2025-11-21 18:06:13.957', '2025-11-21 18:06:13.957', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('2623e13c-2002-4898-99a2-0b4fc49a4ee9', 'Nobesit 500mg Tab', NULL, NULL, NULL, '2025-11-21 18:06:35.554', '2025-11-21 18:06:35.554', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('2c083ed5-5de6-4f00-a64a-47ae8d399fec', 'Met 850mg Tab', NULL, NULL, NULL, '2025-11-21 18:07:01.439', '2025-11-21 18:07:01.439', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('2b4c62e7-3fb9-4b97-864d-36d73b7f7aeb', 'Comet 850mg Tab', NULL, NULL, NULL, '2025-11-21 18:07:20.916', '2025-11-21 18:07:20.916', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('f76658c9-a5db-45c5-ba74-1512824734ea', 'Siglimet 50/500 Tab', NULL, NULL, NULL, '2025-11-21 18:07:46.315', '2025-11-21 18:07:46.315', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('f6fd2a29-c047-4ee0-a7c1-1381943fbe2d', 'Dimerol 80mg', NULL, NULL, NULL, '2025-11-21 18:09:43.963', '2025-11-21 18:09:43.963', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('fa55b2c4-112d-41b8-adb2-f5e632192f47', 'Emjard M XR 5/1000mg', NULL, NULL, NULL, '2025-11-21 18:16:50.16', '2025-11-21 18:16:50.16', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('d899aa82-7ef2-40c4-bcb0-3bd18efb8e28', 'Comet 500mg Tab', NULL, NULL, NULL, '2025-11-21 18:17:29.481', '2025-11-21 18:17:29.481', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('3115916c-2e5c-4e88-a06b-793c227d13f3', 'Comprid 80mg', NULL, NULL, NULL, '2025-11-21 18:49:37.476', '2025-11-21 18:49:37.476', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('1808c1f1-8f20-45a2-b397-7fccbabb0969', 'Bextram Silver A to Z', NULL, NULL, NULL, '2025-11-21 18:46:08.349', '2025-11-21 18:46:08.349', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('d50643f2-ab61-4cae-9836-067fa8a59ae2', 'Diapro 60 MR', NULL, NULL, NULL, '2025-11-21 18:52:09.877', '2025-11-21 18:52:09.877', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('da93723a-ac51-4986-8c8c-e0703bbf33d3', 'Emjard M XR 25/1000', NULL, NULL, NULL, '2025-11-21 18:54:11.377', '2025-11-21 18:54:11.377', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('921082f6-c9ad-4588-b950-dc31b6b7c25c', 'Bextram Gold A to Z', NULL, NULL, NULL, '2025-11-21 19:03:40.304', '2025-11-21 19:03:40.304', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('84f3a7da-379e-472d-ae38-166ea9d71d09', 'V-Plex ampoule', NULL, NULL, NULL, '2025-11-21 19:06:26.481', '2025-11-21 19:06:26.481', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('c7a857de-5634-4eff-93c6-7bb3ada5e735', 'Multivit plus', NULL, NULL, NULL, '2025-11-21 19:08:15.271', '2025-11-21 19:08:15.271', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('2e8b85b0-f8d1-4904-bcc6-352baa971d50', 'napa', NULL, NULL, NULL, '2025-11-21 22:06:32.32', '2025-11-21 22:06:32.32', NULL, NULL, 'GENERAL', 'bbfe6914-675b-4dd6-a172-d1c637e75e27');
INSERT INTO public.products VALUES ('68506d29-84fb-406d-9c65-31d8b77c971d', 'biloba', NULL, NULL, NULL, '2025-11-21 22:06:42.168', '2025-11-21 22:06:42.168', NULL, NULL, 'GENERAL', 'bbfe6914-675b-4dd6-a172-d1c637e75e27');
INSERT INTO public.products VALUES ('87f83da4-b214-4549-97fb-79c04f818040', 'Freedome Sanitary Napkin RFP 240mm', NULL, NULL, NULL, '2025-11-22 05:47:34.491', '2025-11-22 05:47:34.491', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0332bae2-8703-446f-b60c-0c6777407665', 'Twinkle Baby Diaper XXL 24pc', NULL, NULL, NULL, '2025-11-22 05:52:18.164', '2025-11-22 05:52:18.164', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('b9e46bf2-9a4a-4944-9406-ba1e58fd504f', 'Twinkle Baby Diaper M 40pc', NULL, NULL, NULL, '2025-11-22 05:53:07.187', '2025-11-22 05:53:07.187', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('708a2bbc-6567-4035-a321-270e8b403c96', 'Twinkle Baby Diaper S 42pc', NULL, NULL, NULL, '2025-11-22 05:53:40.458', '2025-11-22 05:53:40.458', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('730357ee-3895-41fb-ad4e-bd9f72456ea6', 'Twinkle Baby Diaper XL 32pc', NULL, NULL, NULL, '2025-11-22 05:54:12.719', '2025-11-22 05:54:12.719', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('6eb70b5a-e68d-437d-9da4-0a65fc156451', 'Twinkle Baby Diaper L 34pc', NULL, NULL, NULL, '2025-11-22 05:54:50.957', '2025-11-22 05:54:50.957', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('6a6f9e64-abd9-423d-acf1-d7bdce5e8863', 'Twinkle Baby Diaper M 5pc', NULL, NULL, NULL, '2025-11-22 06:10:06.817', '2025-11-22 06:10:06.817', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('d836af77-e08d-4e73-9c0b-52f1b0e5aae2', 'Twinkle Baby Diaper S 5pc', NULL, NULL, NULL, '2025-11-22 06:11:13.581', '2025-11-22 06:11:13.581', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('c32a0939-b4cb-4de8-8a9f-f7642cfa08cb', 'Twinkle Baby Diaper XL 5pc', NULL, NULL, NULL, '2025-11-22 06:11:25.72', '2025-11-22 06:11:25.72', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('44ff3552-490e-45b8-9430-0219f75f2378', 'Twinkle Baby Diaper XXL 5pc', NULL, NULL, NULL, '2025-11-22 06:11:41.898', '2025-11-22 06:11:41.898', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('11ff3481-7d74-4e50-99d4-490dd82020b8', 'Twinkle Baby Diaper SL 5pc', NULL, NULL, NULL, '2025-11-22 06:11:48.91', '2025-11-22 06:11:48.91', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0d6f338c-abf1-4d53-a8ef-1965aed42a52', 'Freedom Sanitary Napkin Soft 16pc', NULL, NULL, NULL, '2025-11-22 06:19:25.233', '2025-11-22 06:19:25.233', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0f47c960-7f46-47ea-8359-48cfa491482c', 'Freedom Sanitary Napkin Soft 8pc', NULL, NULL, NULL, '2025-11-22 06:19:39.184', '2025-11-22 06:19:39.184', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('310114a9-fe38-460c-a8c1-a7ef6a6dbbf8', 'Mum Mum Baby Diaper L 5pc', NULL, NULL, NULL, '2025-11-22 06:20:40.825', '2025-11-22 06:20:40.825', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('b9f16a97-bffd-4fad-bb17-6a2dac295586', 'Mum Mum Baby Diaper M 5pc', NULL, NULL, NULL, '2025-11-22 06:21:27.544', '2025-11-22 06:21:27.544', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('c13ac820-1fda-4181-bfda-1ae720b0d85a', 'Mum Mum Baby Diaper XL 5pc', NULL, NULL, NULL, '2025-11-22 06:22:09.753', '2025-11-22 06:22:09.753', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('2445b723-f796-42ef-a65d-2f38afd2483b', 'Mum Mum Baby Diaper XXL 5pc', NULL, NULL, NULL, '2025-11-22 06:22:16.68', '2025-11-22 06:22:16.68', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('c541a6e8-2365-4fc6-bdd7-59b296e6537b', 'Mum Mum Baby Diaper S 5pc', NULL, NULL, NULL, '2025-11-22 06:22:26.833', '2025-11-22 06:22:26.833', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('bf926a2a-cd04-42f4-886d-1cbb22e2ded5', 'Rex', NULL, NULL, NULL, '2025-11-22 06:28:32.605', '2025-11-22 06:28:32.605', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('f32a74fb-8dba-41d6-9648-462517b46c67', 'Zanthin 4', NULL, NULL, NULL, '2025-11-22 06:37:20.704', '2025-11-22 06:37:20.704', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0c9f6566-292b-42c0-8a5e-733aa58062ee', 'Zif-Cl', NULL, NULL, NULL, '2025-11-22 06:38:14.231', '2025-11-22 06:38:14.231', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('407252ff-9b1a-4062-8584-fc1352329fcc', 'Ostocal G', NULL, NULL, NULL, '2025-11-22 06:39:18.981', '2025-11-22 06:39:18.981', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('4d69c874-f87a-4cc9-980e-b17edd3dcfcb', 'Calcin-D', NULL, NULL, NULL, '2025-11-22 06:40:16.218', '2025-11-22 06:40:16.218', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('fc317a9e-af62-4014-81af-066450c3ca9c', 'Calmet D', NULL, NULL, NULL, '2025-11-22 06:44:23.828', '2025-11-22 06:44:23.828', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('43a204f8-2a67-4ff8-ae51-8ff2c23d6807', 'Ciprocin 0.3% Eye Drop', NULL, NULL, NULL, '2025-11-22 06:44:49.401', '2025-11-22 06:44:49.401', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('1fe723fa-4041-4929-b8dc-a054e75398d3', 'Povisep 10% Antiseptic Solution', NULL, NULL, NULL, '2025-11-22 06:45:40.424', '2025-11-22 06:45:40.424', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('e5571aa9-36f2-4573-b5a8-23ed4ce1544c', 'Folison 5mg', NULL, NULL, NULL, '2025-11-22 06:46:02.943', '2025-11-22 06:46:02.943', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('faf75c40-315b-476c-b8cd-ab5f95c20bf3', 'Deslor Syrup 60ml', NULL, NULL, NULL, '2025-11-22 06:46:39.877', '2025-11-22 06:46:39.877', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('ace87ab7-3a9f-46bb-b8c7-9432ca953a07', 'Zeefol-Cl', NULL, NULL, NULL, '2025-11-22 06:47:08.072', '2025-11-22 06:47:08.072', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('7163051d-f6ba-4dc1-bf52-7feaa38dfd5c', 'Ratinol Forte', NULL, NULL, NULL, '2025-11-22 06:48:11.261', '2025-11-22 06:48:11.261', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('a924f483-484e-4187-b076-c50203962368', 'E-CAP', NULL, NULL, NULL, '2025-11-22 06:48:56.99', '2025-11-22 06:48:56.99', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('6499f1fe-4fa6-4836-b823-00d43ddd6312', 'Omidon Syrup 60ml', NULL, NULL, NULL, '2025-11-22 06:48:57.833', '2025-11-22 06:48:57.833', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('f83be26b-174f-4fb5-8111-6da3bb2f2d5b', 'Pevisone Cream', NULL, NULL, NULL, '2025-11-22 06:49:56.652', '2025-11-22 06:49:56.652', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('de9558a7-d6b4-46c3-9883-c4cd16c2974a', 'Viodin Ointment 5%', NULL, NULL, NULL, '2025-11-22 06:51:04.272', '2025-11-22 06:51:04.272', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('fda85ff1-80d0-4118-97b0-455062708999', 'CoralMax-D', NULL, NULL, NULL, '2025-11-22 06:52:02.072', '2025-11-22 06:52:02.072', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('8e31e5c2-5bf8-4ff6-8c6a-44f92667e68d', 'Exovate N Cream 25g', NULL, NULL, NULL, '2025-11-22 06:52:23.294', '2025-11-22 06:52:23.294', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('411813fc-00bf-407b-87de-7f6da62a9d5c', 'Ertaco Cream 20g', NULL, NULL, NULL, '2025-11-22 06:53:00.931', '2025-11-22 06:53:00.931', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('0c8910b6-d676-4e26-ae83-e6f19ef773d1', 'Cef-3 Max', NULL, NULL, NULL, '2025-11-22 06:53:27.904', '2025-11-22 06:53:27.904', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('5da1ddc7-ad56-4992-b104-1d13340e0f16', 'Burnsil Cream 25g', NULL, NULL, NULL, '2025-11-22 06:53:52.824', '2025-11-22 06:53:52.824', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('aaad4172-6f6b-44cf-8e5a-916e96bc9afa', 'Tridyl Syrup', NULL, NULL, NULL, '2025-11-22 06:54:41.83', '2025-11-22 06:54:41.83', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('781d6cb1-1e1f-435a-96bc-8653f0821e5b', 'Eyemox Eye Drop 0.5%', NULL, NULL, NULL, '2025-11-22 06:55:04.709', '2025-11-22 06:55:04.709', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');
INSERT INTO public.products VALUES ('9de48886-54b8-4731-9df5-d737ffbf67d4', 'Jasocaine Jelly', NULL, NULL, NULL, '2025-11-22 06:56:03.363', '2025-11-22 06:56:03.363', NULL, NULL, 'GENERAL', '612cb8dc-cf4c-44bf-bded-4be0508f43ac');


--
-- Data for Name: push_subscriptions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.refresh_tokens VALUES ('55cdb866-703e-4571-83b5-b3dce0c2b73e', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNzY4NDgwYS0wYjQxLTQ0M2YtYjJkOS1iY2I2NmVlZTViZTYiLCJpYXQiOjE3NjM3MjkwNzAsImV4cCI6MTc2NDMzMzg3MH0.O3yG4k7H1fugYZapwDKh_5eCm1WJ883bzhSsxDGhkV4', '3768480a-0b41-443f-b2d9-bcb66eee5be6', '2025-11-28 12:44:30.487', '2025-11-21 12:44:30.489');
INSERT INTO public.refresh_tokens VALUES ('118c46a4-17de-42a1-89ed-0124ba2be5ca', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkNDcyMDg5MS01YjAwLTQzZjItODUyOC0wZmQ3MTRhYjg0NmIiLCJpYXQiOjE3NjM3MjkyMDMsImV4cCI6MTc2NDMzNDAwM30.MIZW2BEvqhTuxeGbVQny9lL2MQPaC4OYlCnu19zCQE8', 'd4720891-5b00-43f2-8528-0fd714ab846b', '2025-11-28 12:46:43.676', '2025-11-21 12:46:43.678');
INSERT INTO public.refresh_tokens VALUES ('fd38f02f-0a2d-448a-bb28-4dcfdea37de2', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3MjkyMTAsImV4cCI6MTc2NDMzNDAxMH0.t0rjYEyVo5LhVrvKfOXt2jWC0Wvy_H9nj7k0G6sSpO0', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 12:46:50.802', '2025-11-21 12:46:50.803');
INSERT INTO public.refresh_tokens VALUES ('ad79ed2e-1d61-4bc4-8ee7-194f2a40f392', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkNDcyMDg5MS01YjAwLTQzZjItODUyOC0wZmQ3MTRhYjg0NmIiLCJpYXQiOjE3NjM3Mjk0MTQsImV4cCI6MTc2NDMzNDIxNH0.1lCRg0cWMDZOk_JQrSvxEe6aq0NU_w1hhtsNb0Ib5-4', 'd4720891-5b00-43f2-8528-0fd714ab846b', '2025-11-28 12:50:14.92', '2025-11-21 12:50:14.921');
INSERT INTO public.refresh_tokens VALUES ('2a84728d-ec04-49f6-aaea-9b8d1c0fec20', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkNDcyMDg5MS01YjAwLTQzZjItODUyOC0wZmQ3MTRhYjg0NmIiLCJpYXQiOjE3NjM3MzAwOTksImV4cCI6MTc2NDMzNDg5OX0.hDI2AV_svOZsez3VyjEwrNTH_Rm4UJQ9Aw4hnbKSe-c', 'd4720891-5b00-43f2-8528-0fd714ab846b', '2025-11-28 13:01:39.46', '2025-11-21 13:01:39.461');
INSERT INTO public.refresh_tokens VALUES ('3e5b1be8-2d7e-4148-944e-4bff15dd4543', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3MzcwNDQsImV4cCI6MTc2NDM0MTg0NH0.bPJV9bVKMG5Kde2YlptSiYTxtBZEXQPTnYJmDvPEMy0', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 14:57:24.423', '2025-11-21 14:57:24.424');
INSERT INTO public.refresh_tokens VALUES ('ffdffa1a-2c55-4ae6-bd2c-f8cb5a39ffab', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3MzcxNTMsImV4cCI6MTc2NDM0MTk1M30.mkRIzAZckhmh0KmaFhoNGtMSRk-DlvuT61pSwvV_H4w', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 14:59:13.818', '2025-11-21 14:59:13.819');
INSERT INTO public.refresh_tokens VALUES ('a57755c2-0359-4821-8b47-c1c3c65ae3f8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3Mzc0MjgsImV4cCI6MTc2NDM0MjIyOH0.U8GCgga-yDsvJV6oVAjJ7ydmFGoTmLnVcMjtEioqqJ8', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 15:03:48.983', '2025-11-21 15:03:48.984');
INSERT INTO public.refresh_tokens VALUES ('2330e8b4-0035-4c8b-b4bc-008ef418deab', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNzY4NDgwYS0wYjQxLTQ0M2YtYjJkOS1iY2I2NmVlZTViZTYiLCJpYXQiOjE3NjM3Mzc1MDAsImV4cCI6MTc2NDM0MjMwMH0.5xv-xBPMRkL1I9SCyccUXpQpAHK8gDBoOC9mBs9BSZo', '3768480a-0b41-443f-b2d9-bcb66eee5be6', '2025-11-28 15:05:00.053', '2025-11-21 15:05:00.055');
INSERT INTO public.refresh_tokens VALUES ('680a5c14-680b-41f0-a4fd-2e7f683c86d2', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3Mzc5NDksImV4cCI6MTc2NDM0Mjc0OX0.m8R1z7V-KKdcm0C4wosOboy9PFUN6u44ra3-7Rhbv74', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 15:12:29.567', '2025-11-21 15:12:29.568');
INSERT INTO public.refresh_tokens VALUES ('3617a891-d06f-446a-8c1d-f1adcb524b97', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3Mzc5NTAsImV4cCI6MTc2NDM0Mjc1MH0.lZ6PBBxISNimGmJKvUGzrWGltR5rqC8SDYddZ0e9SHQ', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 15:12:30.477', '2025-11-21 15:12:30.478');
INSERT INTO public.refresh_tokens VALUES ('ad84512e-dd79-49a2-8ef5-4c77bcfab4f1', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3Mzc5NTMsImV4cCI6MTc2NDM0Mjc1M30.ySDb6bZ0dqqCLRm35tfJZMO8yxY96Nzt-1V8wnfQvvw', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 15:12:33.944', '2025-11-21 15:12:33.945');
INSERT INTO public.refresh_tokens VALUES ('e73ebef4-57a7-4de0-901f-febe2e0748fc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3MzgxMTAsImV4cCI6MTc2NDM0MjkxMH0.VqrtsmB_envYTybmkTgtFf3T5C5u4z99L7HgMsEGGH8', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:15:10.01', '2025-11-21 15:15:10.011');
INSERT INTO public.refresh_tokens VALUES ('e11c3c69-4845-42dc-af4b-2e42bdcd9c0e', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3MzgxMTksImV4cCI6MTc2NDM0MjkxOX0.nBHsSMoJdbf_-IlS6pxczy853TuDSJTr3qCvgW6N-m4', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:15:19.597', '2025-11-21 15:15:19.598');
INSERT INTO public.refresh_tokens VALUES ('6b9f5d20-ee7a-48c4-80b4-2aabd91162d6', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3MzgxMjcsImV4cCI6MTc2NDM0MjkyN30.YLkcLeIfiT3omYYG0pVit8Tszsmd-1dg5UGrWU8vMVE', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:15:27.597', '2025-11-21 15:15:27.599');
INSERT INTO public.refresh_tokens VALUES ('869a9250-366e-4ce0-8e42-590e9e2d0366', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3MzgyMjQsImV4cCI6MTc2NDM0MzAyNH0.9WC2j5IL12U8Pr134qXtAPdnWQwdGrGIZt6Fi1izeTE', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:17:04.129', '2025-11-21 15:17:04.13');
INSERT INTO public.refresh_tokens VALUES ('66f0cd97-442f-4d14-bf60-381dbc5b691a', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3MzgyMjksImV4cCI6MTc2NDM0MzAyOX0.vx856FVgdjICEek3zdOES1Y4jNGTT_OESei0KQ_az7Y', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:17:09.592', '2025-11-21 15:17:09.594');
INSERT INTO public.refresh_tokens VALUES ('96a6055e-da89-467f-bee0-ae4cb1bc7873', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3MzgyNDMsImV4cCI6MTc2NDM0MzA0M30.g0-0dGLXKYu-pPmNOT12LkXwoHm60w556BPC2oO_uJU', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:17:23.804', '2025-11-21 15:17:23.805');
INSERT INTO public.refresh_tokens VALUES ('603209be-4d46-413e-b69a-620855f27378', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3MzgyNDksImV4cCI6MTc2NDM0MzA0OX0.Js7KBHrGHttLS4nrcNDDeVQrfT5_JBFOFSrZIJwuUik', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:17:29.651', '2025-11-21 15:17:29.652');
INSERT INTO public.refresh_tokens VALUES ('558f8fc6-ca72-449b-aacb-dedf2e3924fc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3MzgyOTQsImV4cCI6MTc2NDM0MzA5NH0.cE0iRzjB9BDOiI45W2y-Sdt9yA5153W_V-ItlKx4aQ4', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:18:14.817', '2025-11-21 15:18:14.818');
INSERT INTO public.refresh_tokens VALUES ('fea645d1-437e-4b1a-a006-c415f46ff042', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3Mzg0NTEsImV4cCI6MTc2NDM0MzI1MX0.UXka2tV8wZjMZsbHHWetaHUUgxVJhIoZdv4dU1xboxg', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:20:51.944', '2025-11-21 15:20:51.946');
INSERT INTO public.refresh_tokens VALUES ('149357db-d8c7-4f15-b947-017d8cc6599b', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3Mzg0NTksImV4cCI6MTc2NDM0MzI1OX0.8griBjewDyI1dx_3SyIhxImJxlh3ueqR95PjjPmTDIs', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:20:59.464', '2025-11-21 15:20:59.466');
INSERT INTO public.refresh_tokens VALUES ('c8e41987-5da8-44f5-bab0-b137036d2856', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3Mzg1MjgsImV4cCI6MTc2NDM0MzMyOH0.96U2YrjUUT95VuDco6YU-6HaFvVE8W3p4uJuJBCnCDM', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:22:08.593', '2025-11-21 15:22:08.595');
INSERT INTO public.refresh_tokens VALUES ('eb7d319c-ea5f-4c8d-8263-94f57df52ec1', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3Mzg1NDYsImV4cCI6MTc2NDM0MzM0Nn0.JLNrhbX7HNBPxZoOzRJlU6Z93ygrOQgKFzj9lPzgw7g', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:22:26.455', '2025-11-21 15:22:26.456');
INSERT INTO public.refresh_tokens VALUES ('1c8c3d78-3b6d-4633-b0e4-7389870b0113', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3Mzg1NjYsImV4cCI6MTc2NDM0MzM2Nn0.83TpMuawnP-FZTz1BsJ8vZTePzfEb5c5cv76xRvu9dc', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 15:22:46.158', '2025-11-21 15:22:46.159');
INSERT INTO public.refresh_tokens VALUES ('e3c784ce-18da-411b-92d3-0accb552b28f', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3Mzg3MjgsImV4cCI6MTc2NDM0MzUyOH0.NFoDuiCcw3k6Na_dd_2cPnzMvJUkTgqE_Hfd46TIFN8', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:25:28.968', '2025-11-21 15:25:28.969');
INSERT INTO public.refresh_tokens VALUES ('a7e7de62-2caa-4f48-8b9c-80d5714df1d0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3MzkwNjEsImV4cCI6MTc2NDM0Mzg2MX0.-egA5KTfGJVC9qhQEt37Wosa0fMWuYslbzQynlaaiOM', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 15:31:01.267', '2025-11-21 15:31:01.269');
INSERT INTO public.refresh_tokens VALUES ('ebbb3765-daf1-4bfe-b180-a123bf9d0e5d', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3MzkxMTEsImV4cCI6MTc2NDM0MzkxMX0.jxF0TLqq05NMuKy78PyGOdkxAZ0Edz1xXjwPluJNI_o', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 15:31:51.485', '2025-11-21 15:31:51.487');
INSERT INTO public.refresh_tokens VALUES ('a3b76029-5dd5-4a27-bcd1-edf94c159e69', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NDQ0MTMsImV4cCI6MTc2NDM0OTIxM30._yxANKj-Jr_vPTTjXjI2rX3BQKgUuG6JgFkyrdVmmM8', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 17:00:13.679', '2025-11-21 17:00:13.681');
INSERT INTO public.refresh_tokens VALUES ('3ed6082c-592a-46fd-9b78-bb3a648772c2', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NDc4MzcsImV4cCI6MTc2NDM1MjYzN30._S5qhVU_9QZDefFNng5pYVPM6TZhYrTdr9LxkimeuCs', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 17:57:17.72', '2025-11-21 17:57:17.721');
INSERT INTO public.refresh_tokens VALUES ('ed9512e4-e13d-4400-ae14-85b0f5ec4e17', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NDg3MDQsImV4cCI6MTc2NDM1MzUwNH0.MBQRBnrcMvY_RdaWr7YzOMo3QInK-Y9Favp4uR22U5k', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 18:11:44.414', '2025-11-21 18:11:44.416');
INSERT INTO public.refresh_tokens VALUES ('c22c15ae-3783-40ec-b729-2e3f7764d0cb', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NDk5MTQsImV4cCI6MTc2NDM1NDcxNH0.ZGkn9cjbNBWb3m-qjCva9FDN8n6UBCjKZbPAyrS6xq8', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 18:31:54.923', '2025-11-21 18:31:54.924');
INSERT INTO public.refresh_tokens VALUES ('e7a16114-c0db-4d77-8385-f711b599c6ce', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NTI5ODcsImV4cCI6MTc2NDM1Nzc4N30.L1l5cnfm3QvGHOF7ROryIwhqJhhIytVmhZmriiEmruA', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 19:23:07.687', '2025-11-21 19:23:07.688');
INSERT INTO public.refresh_tokens VALUES ('7ecfca70-dda2-40ea-8ba2-877b87594c5c', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NTM4OTgsImV4cCI6MTc2NDM1ODY5OH0.GQowU-MM_Nyl6iEuBLFO9wh64N08VGjQxFHds2uVHlc', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 19:38:18.889', '2025-11-21 19:38:18.89');
INSERT INTO public.refresh_tokens VALUES ('cb356298-db26-41bd-82f2-f6d1dc406ab2', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NTU1MjAsImV4cCI6MTc2NDM2MDMyMH0.aDJ2xJ4ndYkkcor38NMqBxvZjIxR9bQaQ9BP-RpYmnY', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 20:05:20.698', '2025-11-21 20:05:20.699');
INSERT INTO public.refresh_tokens VALUES ('ef43be2e-3e99-4f2b-ba68-4f6097b6d09a', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NTY0MTUsImV4cCI6MTc2NDM2MTIxNX0.6PREaNAqG7vnlBBC5RVUzu4zNU8Gm8rPEk0jPJ9BFzY', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 20:20:15.307', '2025-11-21 20:20:15.311');
INSERT INTO public.refresh_tokens VALUES ('5c65b916-39ec-4da8-b41b-35de4a1fff5f', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NTY0NTksImV4cCI6MTc2NDM2MTI1OX0.GeWCg3I8vyJhURC9bF0shiget7aY1a2z-7PHVj7b4WE', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 20:20:59.677', '2025-11-21 20:20:59.678');
INSERT INTO public.refresh_tokens VALUES ('e314d043-5e0c-4d4b-aed9-cef1f3d27030', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NTY4OTYsImV4cCI6MTc2NDM2MTY5Nn0.Bk8dYr2q8DVA78cyxPe66QKJEYj3qnM4ZL1qoFG2Yok', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 20:28:16.655', '2025-11-21 20:28:16.655');
INSERT INTO public.refresh_tokens VALUES ('712d0f7d-1fc1-48c1-a2cd-5e30591afba1', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NTcyODEsImV4cCI6MTc2NDM2MjA4MX0.DWlDmqGctRVt0KYAmi8qQZ_-zqEtpqrMe3Qm23NfLhs', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 20:34:41.268', '2025-11-21 20:34:41.269');
INSERT INTO public.refresh_tokens VALUES ('4d6357f5-91ff-498d-a71d-8f4135a4a178', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3NTk0ODksImV4cCI6MTc2NDM2NDI4OX0.t7GdPPR3J_ycLmYp7cK4NHHduZ141Ukdt6nJjLzv470', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 21:11:29.231', '2025-11-21 21:11:29.233');
INSERT INTO public.refresh_tokens VALUES ('dd6bd9bc-6f2c-4347-9cc0-2093ad88c317', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3NTk2NDQsImV4cCI6MTc2NDM2NDQ0NH0.rJzdXKx_Et7k1jBBCis_PvOKXiHOX4bT_eJywTKBfyU', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 21:14:04.808', '2025-11-21 21:14:04.809');
INSERT INTO public.refresh_tokens VALUES ('40c289a2-2c25-46ce-8802-37eb980ec39d', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NjAyMjEsImV4cCI6MTc2NDM2NTAyMX0.6dwnMv2tQ8gF2LvwI_LZfX-S7yktkxuPaI_0bBejOYw', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 21:23:41.256', '2025-11-21 21:23:41.258');
INSERT INTO public.refresh_tokens VALUES ('b12a0a79-8d5b-43c4-a365-b84865eda04f', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NjAyNzMsImV4cCI6MTc2NDM2NTA3M30.HAf_2LkzkW1hT84G89cu_-eLR43lDS436I4asV3m1WE', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 21:24:33.782', '2025-11-21 21:24:33.783');
INSERT INTO public.refresh_tokens VALUES ('36744478-089f-41aa-959f-ca5a82680710', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NjAzMzIsImV4cCI6MTc2NDM2NTEzMn0.vms97YcTf4C8TRsbE5COotSfofRdH-akBBszlDSJsx0', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 21:25:32.874', '2025-11-21 21:25:32.875');
INSERT INTO public.refresh_tokens VALUES ('da747d86-4256-4d02-99aa-2926322eded3', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NjIwNDMsImV4cCI6MTc2NDM2Njg0M30.29mtTTOryKyJoaMt_aBYT6BABLLnJvC6TcCBSkbPaIc', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 21:54:03.142', '2025-11-21 21:54:03.143');
INSERT INTO public.refresh_tokens VALUES ('db8d6075-e24a-46a8-ab18-f8d9eb0950e2', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3NjIxODUsImV4cCI6MTc2NDM2Njk4NX0.p38QOb_uaf5vdiAHweU25JAOcDz1PEfY6gDKGg2N-oE', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-28 21:56:25.923', '2025-11-21 21:56:25.925');
INSERT INTO public.refresh_tokens VALUES ('817a257d-5852-4de9-829f-370d650c8ff0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3NjI0MzUsImV4cCI6MTc2NDM2NzIzNX0.tHhYwXuJzVNcTBGf8VJl8DOlBCbn34NRFzahnUdcad0', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 22:00:35.012', '2025-11-21 22:00:35.014');
INSERT INTO public.refresh_tokens VALUES ('96bafad0-f4fd-43ae-9eb6-22fadbb5fabc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiNjMwOTEyYS1kYTQwLTRlOWMtYTkzYS01ZTQxM2MzOTU2MjMiLCJpYXQiOjE3NjM3NjI2OTYsImV4cCI6MTc2NDM2NzQ5Nn0.1JUapVmGDWyBag39u3VVWjZG39zpBAn-4-Su7EMPp-g', 'b630912a-da40-4e9c-a93a-5e413c395623', '2025-11-28 22:04:56.237', '2025-11-21 22:04:56.239');
INSERT INTO public.refresh_tokens VALUES ('b0647998-63dc-4430-8425-79b9ed64237c', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3OTMxMDcsImV4cCI6MTc2NDM5NzkwN30.YWKSrDV7BRw3Io8kkOQ8vxN6wsPHHf0QogZFpDjdNPo', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-29 06:31:47.287', '2025-11-22 06:31:47.289');
INSERT INTO public.refresh_tokens VALUES ('469c46ad-ee11-4804-884b-a93eb7cb3b94', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3OTM3MjEsImV4cCI6MTc2NDM5ODUyMX0.iH8w4WztMYpBKb4mB4Sba53NXRIB-PnK_rRO884VuCw', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-29 06:42:01.269', '2025-11-22 06:42:01.272');
INSERT INTO public.refresh_tokens VALUES ('10995fda-3097-48cf-9919-c46dea64efd1', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzZjI4YTdmNy1iNzE0LTRiYTQtYmYxYS0wOWJiOGEyYTNjNDYiLCJpYXQiOjE3NjM3OTM4MjcsImV4cCI6MTc2NDM5ODYyN30.G-Y_A4cfiavSF0CYYnhhNdI3XRxJ0QEsfCy93EfAV5M', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', '2025-11-29 06:43:47.243', '2025-11-22 06:43:47.244');


--
-- Data for Name: restock_receipts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sale_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sale_items VALUES ('040e0e9a-d83c-48a6-82db-d77b181b1b8d', '28b60286-ab1b-48f1-bd4a-08f572da5ec2', '4380b5fc-4072-4a80-b889-8b33d18f6641', 10, 19, 190, '2025-11-21 19:26:49.082');
INSERT INTO public.sale_items VALUES ('a6814c78-db50-4172-808f-4eb085ef0386', '0907e8c0-4ef8-4bc1-a3dc-330f03f6b4d3', 'bf67c094-9833-4892-8896-278e88c0d3f4', 10, 12, 120, '2025-11-21 19:28:49.812');
INSERT INTO public.sale_items VALUES ('c1bd645e-3836-4f45-a90e-eac7f8e5f911', '8986b35a-07fd-487d-9ba9-dfa567943e11', '25aea772-2943-4968-8cd8-1a81b3d87196', 14, 1.55, 21.7, '2025-11-21 19:30:35.707');
INSERT INTO public.sale_items VALUES ('865113f4-c9de-423f-b22e-e413c834e95a', '6366bdfe-5899-4f73-8745-1598d0cbcfa9', '92ff3693-08d1-44c4-8a24-e624bfc42fa1', 1, 10, 10, '2025-11-21 22:06:53.003');
INSERT INTO public.sale_items VALUES ('0c0dcbae-b971-4248-a97f-5d4bc6920b4d', 'f6107467-283c-4b7b-8956-43c9a9ac3b4f', 'e47272b8-5355-49ac-b0ec-52de45339b5a', 3, 10, 30, '2025-11-21 22:07:25.228');
INSERT INTO public.sale_items VALUES ('92d4d636-a5b9-4963-8f53-67768556d20f', '3487ab37-f15a-4ef3-b717-e9ff0ceb24e2', '6dcc37be-b700-42cb-a92f-0a969e4bfa6a', 2, 30, 60, '2025-11-22 00:47:34.713');
INSERT INTO public.sale_items VALUES ('83a6ccdc-d7b0-46f2-a3d8-65650facd6ac', 'd8bf0340-2e8b-45a6-a232-08ef9117bc21', 'ee1bd0eb-93e9-42e2-b032-8e9103f96b1c', 1, 100, 100, '2025-11-22 06:15:10.27');


--
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sales VALUES ('28b60286-ab1b-48f1-bd4a-08f572da5ec2', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', 'RCP-1763753209081', '2025-11-21 19:26:49.082', 190, 42.8, 'Ridwan Ullah ', '01619717788', 'POS', 'CASH', NULL, 0, '2025-11-21 19:26:49.082', '2025-11-21 19:26:49.082');
INSERT INTO public.sales VALUES ('0907e8c0-4ef8-4bc1-a3dc-330f03f6b4d3', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', 'RCP-1763753329811', '2025-11-21 19:28:49.812', 120, 15, 'Ridwan Ullah ', '01619717788', 'POS', 'CASH', NULL, 0, '2025-11-21 19:28:49.812', '2025-11-21 19:28:49.812');
INSERT INTO public.sales VALUES ('8986b35a-07fd-487d-9ba9-dfa567943e11', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', 'RCP-1763753435706', '2025-11-21 19:30:35.707', 21.7, 2.380000000000002, 'Ridwan Ullah ', '01619717788', 'POS', 'CASH', NULL, 0, '2025-11-21 19:30:35.707', '2025-11-21 19:30:35.707');
INSERT INTO public.sales VALUES ('6366bdfe-5899-4f73-8745-1598d0cbcfa9', 'bbfe6914-675b-4dd6-a172-d1c637e75e27', 'b630912a-da40-4e9c-a93a-5e413c395623', 'RCP-1763762813001', '2025-11-21 22:06:53.003', 10, 2, NULL, NULL, 'POS', 'CASH', NULL, 0, '2025-11-21 22:06:53.003', '2025-11-21 22:06:53.003');
INSERT INTO public.sales VALUES ('f6107467-283c-4b7b-8956-43c9a9ac3b4f', 'bbfe6914-675b-4dd6-a172-d1c637e75e27', 'b630912a-da40-4e9c-a93a-5e413c395623', 'RCP-1763762845226', '2025-11-21 22:07:25.228', 30, 12, NULL, NULL, 'POS', 'CASH', NULL, 0, '2025-11-21 22:07:25.228', '2025-11-21 22:07:25.228');
INSERT INTO public.sales VALUES ('3487ab37-f15a-4ef3-b717-e9ff0ceb24e2', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', 'RCP-1763772454710', '2025-11-22 00:47:34.713', 60, 42, NULL, NULL, 'POS', 'CASH', NULL, 0, '2025-11-22 00:47:34.713', '2025-11-22 00:47:34.713');
INSERT INTO public.sales VALUES ('d8bf0340-2e8b-45a6-a232-08ef9117bc21', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', 'RCP-1763792110269', '2025-11-22 06:15:10.27', 100, 15, NULL, NULL, 'POS', 'CASH', NULL, 0, '2025-11-22 06:15:10.27', '2025-11-22 06:15:10.27');


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tenants VALUES ('612cb8dc-cf4c-44bf-bded-4be0508f43ac', 'Safe Pharma', NULL, NULL, NULL, NULL, NULL, NULL, 'ACTIVE', NULL, NULL, '2025-11-21 12:45:18.424', '2025-11-21 12:45:18.424');
INSERT INTO public.tenants VALUES ('2e0136a8-d74a-408d-b8b6-7656732387d4', 'Demo Shop', NULL, NULL, NULL, NULL, NULL, NULL, 'ACTIVE', NULL, NULL, '2025-11-21 12:46:37.081', '2025-11-21 12:46:37.081');
INSERT INTO public.tenants VALUES ('bbfe6914-675b-4dd6-a172-d1c637e75e27', 'Google User Tenant', NULL, NULL, NULL, NULL, NULL, NULL, 'ACTIVE', NULL, NULL, '2025-11-21 15:05:23.706', '2025-11-21 15:05:23.706');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users VALUES ('3768480a-0b41-443f-b2d9-bcb66eee5be6', 'admin@supershop.com', '$2b$10$JR2BPu9fuLmJvPCInlUJ4OnpqalQ7PuVNfPQTyVH/84XW4x/SA5xW', 'Super Admin', NULL, 'SUPER_ADMIN', NULL, '2025-11-21 12:24:30.862', '2025-11-21 12:24:30.862');
INSERT INTO public.users VALUES ('d4720891-5b00-43f2-8528-0fd714ab846b', 'owner@shop1.com', '$2b$10$akMGrwOePDeU6FlRbrhf9eUbMEj5ea7nWR.Vz.22swf33FcoCA6x6', 'Ishtiaqe Hanif', NULL, 'OWNER', '2e0136a8-d74a-408d-b8b6-7656732387d4', '2025-11-21 12:46:36.877', '2025-11-21 12:46:37.086');
INSERT INTO public.users VALUES ('3f28a7f7-b714-4ba4-bf1a-09bb8a2a3c46', 'ridwan.dpdc@gmail.com', '$2b$10$jikyL16nJVOPFFtqjxSzgO13qICQWwS8wfpwoRiYLoUSYZtng7G2W', 'Ridwan Ullah', NULL, 'OWNER', '612cb8dc-cf4c-44bf-bded-4be0508f43ac', '2025-11-21 12:45:18.071', '2025-11-21 12:45:18.429');
INSERT INTO public.users VALUES ('b630912a-da40-4e9c-a93a-5e413c395623', 'ishtiaqe22@gmail.com', '$2b$10$nlLqIBydREXoa/QnDHyTcOWNIBTMa9OE3vVCloOFX9vPgn5xaEbQa', 'Ishtiaqe Google User', NULL, 'OWNER', 'bbfe6914-675b-4dd6-a172-d1c637e75e27', '2025-11-21 15:05:23.29', '2025-11-21 15:05:23.71');


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: inventory_items inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_pkey PRIMARY KEY (id);


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: push_subscriptions push_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT push_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: restock_receipts restock_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restock_receipts
    ADD CONSTRAINT restock_receipts_pkey PRIMARY KEY (id);


--
-- Name: sale_items sale_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_pkey PRIMARY KEY (id);


--
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: brands_name_tenantId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "brands_name_tenantId_key" ON public.brands USING btree (name, "tenantId");


--
-- Name: brands_tenantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "brands_tenantId_idx" ON public.brands USING btree ("tenantId");


--
-- Name: categories_name_tenantId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "categories_name_tenantId_key" ON public.categories USING btree (name, "tenantId");


--
-- Name: categories_tenantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "categories_tenantId_idx" ON public.categories USING btree ("tenantId");


--
-- Name: inventory_items_expiryDate_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "inventory_items_expiryDate_idx" ON public.inventory_items USING btree ("expiryDate");


--
-- Name: inventory_items_quantity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_items_quantity_idx ON public.inventory_items USING btree (quantity);


--
-- Name: inventory_items_tenantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "inventory_items_tenantId_idx" ON public.inventory_items USING btree ("tenantId");


--
-- Name: inventory_items_variantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "inventory_items_variantId_idx" ON public.inventory_items USING btree ("variantId");


--
-- Name: product_variants_productId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "product_variants_productId_idx" ON public.product_variants USING btree ("productId");


--
-- Name: product_variants_sku_tenantId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "product_variants_sku_tenantId_key" ON public.product_variants USING btree (sku, "tenantId");


--
-- Name: product_variants_tenantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "product_variants_tenantId_idx" ON public.product_variants USING btree ("tenantId");


--
-- Name: products_brandId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "products_brandId_idx" ON public.products USING btree ("brandId");


--
-- Name: products_categoryId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "products_categoryId_idx" ON public.products USING btree ("categoryId");


--
-- Name: products_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_name_idx ON public.products USING btree (name);


--
-- Name: products_productType_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "products_productType_idx" ON public.products USING btree ("productType");


--
-- Name: products_tenantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "products_tenantId_idx" ON public.products USING btree ("tenantId");


--
-- Name: push_subscriptions_endpoint_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX push_subscriptions_endpoint_key ON public.push_subscriptions USING btree (endpoint);


--
-- Name: push_subscriptions_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "push_subscriptions_userId_idx" ON public.push_subscriptions USING btree ("userId");


--
-- Name: refresh_tokens_token_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX refresh_tokens_token_idx ON public.refresh_tokens USING btree (token);


--
-- Name: refresh_tokens_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX refresh_tokens_token_key ON public.refresh_tokens USING btree (token);


--
-- Name: refresh_tokens_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "refresh_tokens_userId_idx" ON public.refresh_tokens USING btree ("userId");


--
-- Name: restock_receipts_receiptNumber_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "restock_receipts_receiptNumber_idx" ON public.restock_receipts USING btree ("receiptNumber");


--
-- Name: restock_receipts_tenantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "restock_receipts_tenantId_idx" ON public.restock_receipts USING btree ("tenantId");


--
-- Name: sale_items_inventoryId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "sale_items_inventoryId_idx" ON public.sale_items USING btree ("inventoryId");


--
-- Name: sale_items_saleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "sale_items_saleId_idx" ON public.sale_items USING btree ("saleId");


--
-- Name: sales_receiptNumber_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "sales_receiptNumber_idx" ON public.sales USING btree ("receiptNumber");


--
-- Name: sales_receiptNumber_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "sales_receiptNumber_key" ON public.sales USING btree ("receiptNumber");


--
-- Name: sales_saleTime_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "sales_saleTime_idx" ON public.sales USING btree ("saleTime");


--
-- Name: sales_tenantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "sales_tenantId_idx" ON public.sales USING btree ("tenantId");


--
-- Name: suppliers_tenantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "suppliers_tenantId_idx" ON public.suppliers USING btree ("tenantId");


--
-- Name: tenants_registrationNumber_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "tenants_registrationNumber_key" ON public.tenants USING btree ("registrationNumber");


--
-- Name: tenants_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tenants_status_idx ON public.tenants USING btree (status);


--
-- Name: users_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_email_idx ON public.users USING btree (email);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: users_tenantId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "users_tenantId_idx" ON public.users USING btree ("tenantId");


--
-- Name: brands brands_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT "brands_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categories categories_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "categories_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_items inventory_items_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT "inventory_items_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_items inventory_items_variantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT "inventory_items_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES public.product_variants(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_variants product_variants_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT "product_variants_productId_fkey" FOREIGN KEY ("productId") REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variants product_variants_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT "product_variants_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: products products_brandId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "products_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES public.brands(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: products products_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "products_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: products products_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "products_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: push_subscriptions push_subscriptions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT "push_subscriptions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "refresh_tokens_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restock_receipts restock_receipts_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restock_receipts
    ADD CONSTRAINT "restock_receipts_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public.suppliers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: restock_receipts restock_receipts_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restock_receipts
    ADD CONSTRAINT "restock_receipts_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sale_items sale_items_inventoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT "sale_items_inventoryId_fkey" FOREIGN KEY ("inventoryId") REFERENCES public.inventory_items(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sale_items sale_items_saleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT "sale_items_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES public.sales(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sales sales_employeeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT "sales_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sales sales_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT "sales_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: suppliers suppliers_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT "suppliers_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 0RI5kmozo6A5oGOSpNJKsHkJcc5JaZC2NHWdolXeA9SduABR0uMnNrZAMSvedES

