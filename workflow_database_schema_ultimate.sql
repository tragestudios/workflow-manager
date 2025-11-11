--
-- PostgreSQL database dump
--

\restrict khTGfDoHuB4RTKlhZcl5qnQKdbb38Pf4HnTOznoiWSQoJTHcOaLZQSmggGG6hfF

-- Dumped from database version 17.6 (Debian 17.6-1.pgdg13+1)
-- Dumped by pg_dump version 17.6 (Debian 17.6-1.pgdg13+1)

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

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: file_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.file_type AS ENUM (
    'image',
    'audio',
    'document',
    'other'
);


ALTER TYPE public.file_type OWNER TO postgres;

--
-- Name: invitation_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.invitation_status AS ENUM (
    'pending',
    'approved',
    'rejected',
    'revoked'
);


ALTER TYPE public.invitation_status OWNER TO postgres;

--
-- Name: member_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.member_role AS ENUM (
    'owner',
    'admin',
    'member'
);


ALTER TYPE public.member_role OWNER TO postgres;

--
-- Name: node_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.node_status AS ENUM (
    'not_started',
    'in_progress',
    'completed'
);


ALTER TYPE public.node_status OWNER TO postgres;

--
-- Name: node_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.node_type AS ENUM (
    'start',
    'process',
    'decision',
    'end'
);


ALTER TYPE public.node_type OWNER TO postgres;

--
-- Name: task_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.task_status AS ENUM (
    'pending',
    'in_progress',
    'completed'
);


ALTER TYPE public.task_status OWNER TO postgres;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'user'
);


ALTER TYPE public.user_role OWNER TO postgres;

--
-- Name: user_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_status AS ENUM (
    'pending',
    'active',
    'inactive'
);


ALTER TYPE public.user_status OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

--
-- Name: update_workflow_members_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_workflow_members_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_workflow_members_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: connections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.connections (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    source_node_id uuid NOT NULL,
    target_node_id uuid NOT NULL,
    label character varying(255),
    style jsonb,
    workflow_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    source_connector character varying(20)
);


ALTER TABLE public.connections OWNER TO postgres;

--
-- Name: COLUMN connections.source_connector; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.connections.source_connector IS 'Type of source connector used: output, output-yes, output-no for decision nodes';


--
-- Name: files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.files (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    filename character varying(255) NOT NULL,
    original_name character varying(255) NOT NULL,
    mime_type character varying(100) NOT NULL,
    size integer NOT NULL,
    path character varying(500) NOT NULL,
    type public.file_type NOT NULL,
    node_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.files OWNER TO postgres;

--
-- Name: nodes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nodes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    type public.node_type NOT NULL,
    status public.node_status DEFAULT 'not_started'::public.node_status,
    progress_percentage integer DEFAULT 0,
    "position" jsonb NOT NULL,
    style jsonb,
    notes text,
    workflow_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.nodes OWNER TO postgres;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    status public.task_status DEFAULT 'pending'::public.task_status,
    due_date timestamp with time zone,
    progress_percentage integer DEFAULT 0,
    node_id uuid NOT NULL,
    assigned_to_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role public.user_role DEFAULT 'user'::public.user_role,
    status public.user_status DEFAULT 'pending'::public.user_status,
    avatar character varying(255),
    invited_by character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: workflow_invitations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_invitations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    invite_code character varying(20) NOT NULL,
    workflow_id uuid NOT NULL,
    invited_by_id uuid NOT NULL,
    invited_user_id uuid,
    status public.invitation_status DEFAULT 'pending'::public.invitation_status,
    message text,
    responded_at timestamp with time zone,
    is_used boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.workflow_invitations OWNER TO postgres;

--
-- Name: workflow_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workflow_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role public.member_role DEFAULT 'member'::public.member_role,
    joined_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.workflow_members OWNER TO postgres;

--
-- Name: workflows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflows (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    metadata jsonb,
    is_public boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_by_id uuid NOT NULL,
    invite_code character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.workflows OWNER TO postgres;

--
-- Data for Name: connections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.connections (id, source_node_id, target_node_id, label, style, workflow_id, created_at, source_connector) FROM stdin;
7baaad56-5d31-4477-84d6-04e0e0092a18	79e32ead-85ad-46e4-bf8c-5808965ac2c0	d21c31e6-6ead-4f72-a409-fca93bd1cb80	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.590247+00	output
e70e42fd-cb67-499d-8e10-4177c5ba8bf7	d21c31e6-6ead-4f72-a409-fca93bd1cb80	0be8778e-c445-496a-8a7e-960de209967b	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.602404+00	output
b43af140-c792-4da5-9060-7c385cac991e	0be8778e-c445-496a-8a7e-960de209967b	dcace4ed-4dfe-41e0-bde4-00de4bf2614a	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.614426+00	output-yes
8b07c5a1-c4bd-42b8-8863-f9f3bf586fd5	0be8778e-c445-496a-8a7e-960de209967b	503656ea-afc6-4612-92a1-dacfc241068a	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.627185+00	output-no
4db67c2c-54d5-46e0-8e59-5b659660c165	16f41873-644e-47a0-a30d-3314c705627c	a4192ea9-ddf1-42fe-ad6e-698ca72e17b9	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.640399+00	output-yes
a33a8d45-4488-4d89-881c-e357d42393ab	16f41873-644e-47a0-a30d-3314c705627c	2bfcfd7e-8f5c-436b-bfbe-e4a4c2d61fe0	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.654868+00	output-no
98e43411-0540-4eeb-b325-cc44f6d78c6b	3d19d4e7-1b71-4aa1-9ea6-93fb28b553b1	a4192ea9-ddf1-42fe-ad6e-698ca72e17b9	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.666801+00	output-yes
67c6c910-fb85-48fd-8580-45f60a345c6e	3d19d4e7-1b71-4aa1-9ea6-93fb28b553b1	2bfcfd7e-8f5c-436b-bfbe-e4a4c2d61fe0	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.678488+00	output-no
c24f6ab0-f197-49bf-82a5-0a06065d7a6a	d21c31e6-6ead-4f72-a409-fca93bd1cb80	16f41873-644e-47a0-a30d-3314c705627c	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.69095+00	output
e83d55a2-fdbe-4d1f-be1d-5d0368760095	dcace4ed-4dfe-41e0-bde4-00de4bf2614a	8f433161-f198-44d7-b7f0-68b4bbb63459	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.702935+00	output
cc9af8e4-d433-4685-83af-da033f1b4674	503656ea-afc6-4612-92a1-dacfc241068a	8f433161-f198-44d7-b7f0-68b4bbb63459	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.715362+00	output
352e680e-e3f3-4c47-b490-5d97dfeb4b12	a4192ea9-ddf1-42fe-ad6e-698ca72e17b9	8f433161-f198-44d7-b7f0-68b4bbb63459	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.727603+00	output
64ddc96d-0d8a-47cd-b899-6efee6313861	2bfcfd7e-8f5c-436b-bfbe-e4a4c2d61fe0	8f433161-f198-44d7-b7f0-68b4bbb63459	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.738994+00	output
21c2c7f3-d84b-43b7-97c6-3ccac88166c0	79e32ead-85ad-46e4-bf8c-5808965ac2c0	3d19d4e7-1b71-4aa1-9ea6-93fb28b553b1	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.750698+00	\N
c011d1be-285a-4801-9704-c8b8d93c0bf8	0ced950e-9e08-4b0f-8ba0-0d508dbd9a45	16f41873-644e-47a0-a30d-3314c705627c	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.763383+00	output-yes
d920c559-0f02-4d9e-ad8e-100f5dab1b70	0ced950e-9e08-4b0f-8ba0-0d508dbd9a45	3d19d4e7-1b71-4aa1-9ea6-93fb28b553b1	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.77641+00	output-no
34e18e95-f7f3-4bbc-96c9-ebe977e65b4d	79e32ead-85ad-46e4-bf8c-5808965ac2c0	0ced950e-9e08-4b0f-8ba0-0d508dbd9a45	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.790187+00	\N
93bfd35b-2f41-450e-a301-425b73a22679	74cd9881-1a7c-436c-a4d0-c41c5013b34d	d060dc2f-470e-428e-af7c-66c994f4693b	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.450331+00	\N
ca917eed-ada5-4957-bcb4-e00e9f63eb6a	d060dc2f-470e-428e-af7c-66c994f4693b	3ddf0dff-e78a-43f8-9211-8b7be1e1ef3d	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.453202+00	\N
9832f8f0-2078-411d-b141-7c36d1a03517	3ddf0dff-e78a-43f8-9211-8b7be1e1ef3d	d8af50cd-0e98-4677-b8e7-ef71f0900a72	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.455971+00	\N
b5fdd587-0918-466c-af99-4411c38753ad	74cd9881-1a7c-436c-a4d0-c41c5013b34d	0df8a082-bfb3-402c-8d91-7a8bd37bec47	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.458932+00	\N
393902a8-aaa2-46e8-a575-457767fec289	0df8a082-bfb3-402c-8d91-7a8bd37bec47	d8af50cd-0e98-4677-b8e7-ef71f0900a72	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.461576+00	\N
7055c453-2ccc-4e4d-8c86-abe926a9ce01	d060dc2f-470e-428e-af7c-66c994f4693b	be4294a7-220a-41ef-bfe2-ccbc2708e38c	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.464188+00	\N
02160793-5a6a-4fca-88ca-1597858788ac	be4294a7-220a-41ef-bfe2-ccbc2708e38c	d8af50cd-0e98-4677-b8e7-ef71f0900a72	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.466766+00	\N
42a244f0-461a-4dee-bc81-86b9591aa993	8390150d-8867-425a-bbc7-43bcda5b9bac	0df8a082-bfb3-402c-8d91-7a8bd37bec47	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.469374+00	\N
ae3f385c-0455-470c-a55d-cc6a2a006a01	9289172b-9a12-4a55-8703-d6a227454058	0df8a082-bfb3-402c-8d91-7a8bd37bec47	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.472821+00	\N
e2d1e3fa-7c79-419b-acf5-f87e459675fc	9289172b-9a12-4a55-8703-d6a227454058	d060dc2f-470e-428e-af7c-66c994f4693b	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.47637+00	\N
2240498c-d30f-438c-a0a8-dc40dae06d62	9289172b-9a12-4a55-8703-d6a227454058	c5246246-c238-49bb-a8d2-0151017d6ede	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.47901+00	\N
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.files (id, filename, original_name, mime_type, size, path, type, node_id, created_at) FROM stdin;
\.


--
-- Data for Name: nodes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nodes (id, name, description, type, status, progress_percentage, "position", style, notes, workflow_id, created_at, updated_at) FROM stdin;
0ced950e-9e08-4b0f-8ba0-0d508dbd9a45	Decision Node	\N	decision	not_started	0	{"x": 210, "y": 451}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.575693+00	2025-10-03 08:22:27.237738+00
3d19d4e7-1b71-4aa1-9ea6-93fb28b553b1	Decision Node	\N	decision	not_started	0	{"x": 713, "y": 509}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.556181+00	2025-10-03 08:22:28.143595+00
a4192ea9-ddf1-42fe-ad6e-698ca72e17b9	Process Node	\N	process	not_started	0	{"x": 1076, "y": 268}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.500512+00	2025-10-03 08:22:29.160184+00
8f433161-f198-44d7-b7f0-68b4bbb63459	End Node	\N	end	not_started	0	{"x": 1569, "y": 187}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.56549+00	2025-10-03 08:22:30.005895+00
0be8778e-c445-496a-8a7e-960de209967b	Decision Node	\N	decision	not_started	0	{"x": 688, "y": 40}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.489094+00	2025-10-03 08:24:08.969564+00
74cd9881-1a7c-436c-a4d0-c41c5013b34d	Start Node	\N	start	not_started	0	{"x": 436, "y": 286}	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.417276+00	2025-10-03 13:10:46.417276+00
79e32ead-85ad-46e4-bf8c-5808965ac2c0	Start Node	Bu nod denemedir	start	not_started	0	{"x": -110, "y": 218}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.459616+00	2025-10-03 08:25:04.392732+00
d21c31e6-6ead-4f72-a409-fca93bd1cb80	Process Node	\N	process	not_started	80	{"x": 284, "y": 29}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.534105+00	2025-10-03 08:25:10.017343+00
d060dc2f-470e-428e-af7c-66c994f4693b	Process Node	\N	process	not_started	0	{"x": 749, "y": 286}	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.420969+00	2025-10-03 13:10:46.420969+00
3ddf0dff-e78a-43f8-9211-8b7be1e1ef3d	Decision Node	\N	decision	not_started	0	{"x": 1052, "y": 146}	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.428015+00	2025-10-03 13:10:46.428015+00
be4294a7-220a-41ef-bfe2-ccbc2708e38c	Process Node	\N	process	not_started	0	{"x": 1036, "y": 299}	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.432646+00	2025-10-03 13:10:46.432646+00
d8af50cd-0e98-4677-b8e7-ef71f0900a72	End Node	\N	end	not_started	0	{"x": 1401, "y": 309}	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.436037+00	2025-10-03 13:10:46.436037+00
9289172b-9a12-4a55-8703-d6a227454058	Start Node	\N	start	not_started	0	{"x": 391, "y": 412}	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.439696+00	2025-10-03 13:10:46.439696+00
8390150d-8867-425a-bbc7-43bcda5b9bac	Start Node	\N	start	not_started	0	{"x": 409, "y": 528}	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.443302+00	2025-10-03 13:10:46.443302+00
c5246246-c238-49bb-a8d2-0151017d6ede	Process Node	\N	process	not_started	0	{"x": 688, "y": 566}	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.446998+00	2025-10-03 13:10:46.446998+00
0df8a082-bfb3-402c-8d91-7a8bd37bec47	Process Node	\N	process	not_started	0	{"x": 904, "y": 427}	\N	\N	140f11b3-69dd-4d55-acd8-5533d8c456b6	2025-10-03 13:10:46.424183+00	2025-10-03 13:12:25.841935+00
16f41873-644e-47a0-a30d-3314c705627c	Decision Node	\N	decision	not_started	0	{"x": 729, "y": 290}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.514195+00	2025-10-02 19:44:01.227336+00
2bfcfd7e-8f5c-436b-bfbe-e4a4c2d61fe0	Process Node	\N	process	not_started	0	{"x": 1100, "y": 453}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.478348+00	2025-10-03 08:22:20.319965+00
503656ea-afc6-4612-92a1-dacfc241068a	Process Node	\N	process	not_started	0	{"x": 1105, "y": 104}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.523645+00	2025-10-03 08:22:22.279589+00
dcace4ed-4dfe-41e0-bde4-00de4bf2614a	Process Node	\N	process	not_started	0	{"x": 1109, "y": -106}	\N	\N	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	2025-10-01 19:23:37.545247+00	2025-10-03 08:22:23.18133+00
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, title, description, status, due_date, progress_percentage, node_id, assigned_to_id, created_at, updated_at) FROM stdin;
6a66cd44-7c0d-43ab-ae80-522e5947efa3	Bu da ikinci		completed	\N	0	d21c31e6-6ead-4f72-a409-fca93bd1cb80	6941aedd-ddba-4a0e-baec-5421521b3fc5	2025-10-02 19:38:30.059645+00	2025-10-02 19:40:29.06905+00
ca6f3fcd-b3ba-40e3-9d01-0d0d50d0299c	dawdaw	dawdaw	completed	\N	0	d21c31e6-6ead-4f72-a409-fca93bd1cb80	174081fd-5f4d-4849-b1ef-62f0364f13dd	2025-10-02 19:41:18.118506+00	2025-10-02 19:44:35.046759+00
f7cbe928-a362-4816-8f6e-f7bb4db30258	grrd	gdrgdrg	pending	\N	0	79e32ead-85ad-46e4-bf8c-5808965ac2c0	6941aedd-ddba-4a0e-baec-5421521b3fc5	2025-10-02 19:45:33.00479+00	2025-10-02 19:45:36.279853+00
87785c55-c4e4-44d9-894a-84d3e6fbf339	sxzcszc	czsczsc	pending	\N	0	d21c31e6-6ead-4f72-a409-fca93bd1cb80	174081fd-5f4d-4849-b1ef-62f0364f13dd	2025-10-03 08:19:41.83472+00	2025-10-03 08:19:41.83472+00
0f51a277-634e-4f71-92ee-a602814aa07f	es	ese	completed	\N	0	d21c31e6-6ead-4f72-a409-fca93bd1cb80	6941aedd-ddba-4a0e-baec-5421521b3fc5	2025-10-02 19:42:37.811661+00	2025-10-03 08:19:51.061604+00
e25e5375-30f2-4dba-a23b-8c09f033609a	Yeni görev		completed	\N	0	d21c31e6-6ead-4f72-a409-fca93bd1cb80	6941aedd-ddba-4a0e-baec-5421521b3fc5	2025-10-02 19:38:16.952659+00	2025-10-03 08:19:55.055544+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, name, password, role, status, avatar, invited_by, created_at, updated_at) FROM stdin;
6941aedd-ddba-4a0e-baec-5421521b3fc5	garslan686@gmail.com	Emirhan Arslan	$2a$12$LA8q4f5uXvYFKRqkjgzPbe0vOhae9UkMF8u377tQ3FuKgzBUytRta	user	active	\N	\N	2025-09-29 17:55:26.574997+00	2025-09-29 17:55:26.574997+00
174081fd-5f4d-4849-b1ef-62f0364f13dd	deneme@gmail.com	efesfsf	$2a$12$b651d8lBjYQemyukf/TwGeqmnx04agFK/Aug0ZHTl9UqOC2Q9vfwu	user	active	\N	\N	2025-09-29 17:55:56.914104+00	2025-09-29 17:55:56.914104+00
\.


--
-- Data for Name: workflow_invitations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_invitations (id, invite_code, workflow_id, invited_by_id, invited_user_id, status, message, responded_at, is_used, created_at, updated_at) FROM stdin;
a3d6fba1-8620-49cb-b5ce-4e52bf842a4b	E0693D3C-9B615A2A	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	6941aedd-ddba-4a0e-baec-5421521b3fc5	174081fd-5f4d-4849-b1ef-62f0364f13dd	approved	\N	2025-10-02 19:39:53.407+00	t	2025-10-02 19:39:49.343562+00	2025-10-02 19:39:53.412887+00
04decdc7-8a8e-48fe-888d-1cadfd466814	E0693D3C-8FC41446	8fc41446-1e54-4163-a809-a0ab3ffb4bd7	6941aedd-ddba-4a0e-baec-5421521b3fc5	174081fd-5f4d-4849-b1ef-62f0364f13dd	approved	\N	2025-10-03 13:08:37.421+00	t	2025-10-03 13:08:29.653765+00	2025-10-03 13:08:37.42512+00
\.


--
-- Data for Name: workflow_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_members (id, workflow_id, user_id, role, joined_at, created_at, updated_at) FROM stdin;
fbc068ed-0f3e-4c4d-a96b-297e04117ace	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	6941aedd-ddba-4a0e-baec-5421521b3fc5	owner	2025-10-01 15:26:44.550641+00	2025-10-01 15:26:44.550641+00	2025-10-01 15:26:44.550641+00
f701c597-67be-4c6d-91e9-e39448621c85	9b615a2a-4c81-4e5f-8a22-5790af57f5f7	174081fd-5f4d-4849-b1ef-62f0364f13dd	member	2025-10-02 19:39:53.420598+00	2025-10-02 19:39:53.420598+00	2025-10-02 19:39:53.420598+00
8e5c674b-f9b2-4062-97d4-3ff923dc48f1	8fc41446-1e54-4163-a809-a0ab3ffb4bd7	6941aedd-ddba-4a0e-baec-5421521b3fc5	owner	2025-10-03 13:06:11.002948+00	2025-10-03 13:06:11.002948+00	2025-10-03 13:06:11.002948+00
ea3e2405-60a8-414d-be69-eacd22c0c40c	8fc41446-1e54-4163-a809-a0ab3ffb4bd7	174081fd-5f4d-4849-b1ef-62f0364f13dd	member	2025-10-03 13:08:37.433652+00	2025-10-03 13:08:37.433652+00	2025-10-03 13:08:37.433652+00
21ddd1c1-f976-456b-92ff-6f95b20e4237	140f11b3-69dd-4d55-acd8-5533d8c456b6	6941aedd-ddba-4a0e-baec-5421521b3fc5	owner	2025-10-03 13:10:46.4123+00	2025-10-03 13:10:46.4123+00	2025-10-03 13:10:46.4123+00
\.


--
-- Data for Name: workflows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflows (id, name, description, metadata, is_public, is_active, created_by_id, invite_code, created_at, updated_at) FROM stdin;
9b615a2a-4c81-4e5f-8a22-5790af57f5f7	dawda	adwdaw	\N	f	t	6941aedd-ddba-4a0e-baec-5421521b3fc5	E0693D3C-9B615A2A	2025-10-01 15:26:44.531454+00	2025-10-01 19:24:22.166655+00
8fc41446-1e54-4163-a809-a0ab3ffb4bd7	EDANIN UYGULAMA	\N	\N	f	t	6941aedd-ddba-4a0e-baec-5421521b3fc5	E0693D3C-8FC41446	2025-10-03 13:06:10.968013+00	2025-10-03 13:06:10.990576+00
140f11b3-69dd-4d55-acd8-5533d8c456b6	Emirhan Arslan	daawd	\N	f	t	6941aedd-ddba-4a0e-baec-5421521b3fc5	E0693D3C-140F11B3	2025-10-03 13:10:46.393592+00	2025-10-03 13:10:46.407813+00
\.


--
-- Name: connections connections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: nodes nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: workflow_members unique_workflow_member; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_members
    ADD CONSTRAINT unique_workflow_member UNIQUE (workflow_id, user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workflow_invitations workflow_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_invitations
    ADD CONSTRAINT workflow_invitations_pkey PRIMARY KEY (id);


--
-- Name: workflow_members workflow_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_members
    ADD CONSTRAINT workflow_members_pkey PRIMARY KEY (id);


--
-- Name: workflows workflows_invite_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_invite_code_key UNIQUE (invite_code);


--
-- Name: workflows workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_pkey PRIMARY KEY (id);


--
-- Name: idx_connections_source_connector; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_connections_source_connector ON public.connections USING btree (source_connector);


--
-- Name: idx_connections_source_node_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_connections_source_node_id ON public.connections USING btree (source_node_id);


--
-- Name: idx_connections_target_node_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_connections_target_node_id ON public.connections USING btree (target_node_id);


--
-- Name: idx_connections_workflow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_connections_workflow_id ON public.connections USING btree (workflow_id);


--
-- Name: idx_files_node_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_node_id ON public.files USING btree (node_id);


--
-- Name: idx_files_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_type ON public.files USING btree (type);


--
-- Name: idx_nodes_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_nodes_status ON public.nodes USING btree (status);


--
-- Name: idx_nodes_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_nodes_type ON public.nodes USING btree (type);


--
-- Name: idx_nodes_workflow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_nodes_workflow_id ON public.nodes USING btree (workflow_id);


--
-- Name: idx_tasks_assigned_to_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_assigned_to_id ON public.tasks USING btree (assigned_to_id);


--
-- Name: idx_tasks_due_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_due_date ON public.tasks USING btree (due_date);


--
-- Name: idx_tasks_node_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_node_id ON public.tasks USING btree (node_id);


--
-- Name: idx_tasks_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_status ON public.tasks USING btree (status);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: idx_users_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_status ON public.users USING btree (status);


--
-- Name: idx_workflow_invitations_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_invitations_created_at ON public.workflow_invitations USING btree (created_at);


--
-- Name: idx_workflow_invitations_invite_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_invitations_invite_code ON public.workflow_invitations USING btree (invite_code);


--
-- Name: idx_workflow_invitations_invited_by_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_invitations_invited_by_id ON public.workflow_invitations USING btree (invited_by_id);


--
-- Name: idx_workflow_invitations_invited_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_invitations_invited_user_id ON public.workflow_invitations USING btree (invited_user_id);


--
-- Name: idx_workflow_invitations_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_invitations_status ON public.workflow_invitations USING btree (status);


--
-- Name: idx_workflow_invitations_user_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_invitations_user_status ON public.workflow_invitations USING btree (invited_user_id, status);


--
-- Name: idx_workflow_invitations_workflow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_invitations_workflow_id ON public.workflow_invitations USING btree (workflow_id);


--
-- Name: idx_workflow_invitations_workflow_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_invitations_workflow_status ON public.workflow_invitations USING btree (workflow_id, status);


--
-- Name: idx_workflow_members_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_members_role ON public.workflow_members USING btree (role);


--
-- Name: idx_workflow_members_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_members_user_id ON public.workflow_members USING btree (user_id);


--
-- Name: idx_workflow_members_workflow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflow_members_workflow_id ON public.workflow_members USING btree (workflow_id);


--
-- Name: idx_workflows_created_by_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflows_created_by_id ON public.workflows USING btree (created_by_id);


--
-- Name: idx_workflows_invite_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflows_invite_code ON public.workflows USING btree (invite_code);


--
-- Name: idx_workflows_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflows_is_active ON public.workflows USING btree (is_active);


--
-- Name: idx_workflows_is_public; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_workflows_is_public ON public.workflows USING btree (is_public);


--
-- Name: unique_pending_invitation_only; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_pending_invitation_only ON public.workflow_invitations USING btree (workflow_id, invited_user_id) WHERE (status = 'pending'::public.invitation_status);


--
-- Name: nodes trigger_nodes_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_nodes_updated_at BEFORE UPDATE ON public.nodes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: tasks trigger_tasks_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_tasks_updated_at BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users trigger_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: workflow_invitations trigger_workflow_invitations_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_workflow_invitations_updated_at BEFORE UPDATE ON public.workflow_invitations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: workflow_members trigger_workflow_members_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_workflow_members_updated_at BEFORE UPDATE ON public.workflow_members FOR EACH ROW EXECUTE FUNCTION public.update_workflow_members_updated_at();


--
-- Name: workflows trigger_workflows_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_workflows_updated_at BEFORE UPDATE ON public.workflows FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: connections fk_connections_source_node_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT fk_connections_source_node_id FOREIGN KEY (source_node_id) REFERENCES public.nodes(id) ON DELETE CASCADE;


--
-- Name: connections fk_connections_target_node_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT fk_connections_target_node_id FOREIGN KEY (target_node_id) REFERENCES public.nodes(id) ON DELETE CASCADE;


--
-- Name: connections fk_connections_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT fk_connections_workflow_id FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: files fk_files_node_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT fk_files_node_id FOREIGN KEY (node_id) REFERENCES public.nodes(id) ON DELETE CASCADE;


--
-- Name: nodes fk_nodes_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT fk_nodes_workflow_id FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: tasks fk_tasks_assigned_to_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT fk_tasks_assigned_to_id FOREIGN KEY (assigned_to_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tasks fk_tasks_node_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT fk_tasks_node_id FOREIGN KEY (node_id) REFERENCES public.nodes(id) ON DELETE CASCADE;


--
-- Name: workflow_invitations fk_workflow_invitations_invited_by_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_invitations
    ADD CONSTRAINT fk_workflow_invitations_invited_by_id FOREIGN KEY (invited_by_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workflow_invitations fk_workflow_invitations_invited_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_invitations
    ADD CONSTRAINT fk_workflow_invitations_invited_user_id FOREIGN KEY (invited_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workflow_invitations fk_workflow_invitations_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_invitations
    ADD CONSTRAINT fk_workflow_invitations_workflow_id FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: workflow_members fk_workflow_members_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_members
    ADD CONSTRAINT fk_workflow_members_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workflow_members fk_workflow_members_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_members
    ADD CONSTRAINT fk_workflow_members_workflow_id FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: workflows fk_workflows_created_by_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT fk_workflows_created_by_id FOREIGN KEY (created_by_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict khTGfDoHuB4RTKlhZcl5qnQKdbb38Pf4HnTOznoiWSQoJTHcOaLZQSmggGG6hfF

