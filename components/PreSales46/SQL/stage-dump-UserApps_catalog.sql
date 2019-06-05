--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

DROP INDEX public.user_apps_manager_ip_username_mode_tenant;
ALTER TABLE ONLY public."UserApps" DROP CONSTRAINT "UserApps_pkey";
ALTER TABLE public."UserApps" ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public."UserApps_id_seq";
DROP TABLE public."UserApps";
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: UserApps; Type: TABLE; Schema: public; Owner: cloudify
--

CREATE TABLE "UserApps" (
    id integer NOT NULL,
    "managerIp" character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    "appDataVersion" integer NOT NULL,
    mode "enum_UserApps_mode" DEFAULT 'main'::"enum_UserApps_mode" NOT NULL,
    "appData" json NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    tenant character varying(255) DEFAULT 'default_tenant'::character varying NOT NULL
);


ALTER TABLE "UserApps" OWNER TO cloudify;

--
-- Name: UserApps_id_seq; Type: SEQUENCE; Schema: public; Owner: cloudify
--

CREATE SEQUENCE "UserApps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "UserApps_id_seq" OWNER TO cloudify;

--
-- Name: UserApps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cloudify
--

ALTER SEQUENCE "UserApps_id_seq" OWNED BY "UserApps".id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cloudify
--

ALTER TABLE ONLY "UserApps" ALTER COLUMN id SET DEFAULT nextval('"UserApps_id_seq"'::regclass);


--
-- Data for Name: UserApps; Type: TABLE DATA; Schema: public; Owner: cloudify
--

COPY "UserApps" (id, "managerIp", username, "appDataVersion", mode, "appData", "createdAt", "updatedAt", tenant) FROM stdin;
1	127.0.0.1	admin	4	main	{"pages":[{"id":"dashboard","name":"Dashboard","description":"","widgets":[{"id":"45d76769-0db5-4b39-8ae9-266609a8a5db","name":"Deployment Wizard Buttons","width":2,"height":11,"x":0,"y":0,"definition":"deploymentWizardButtons","configuration":{"showHelloWorldWizardButton":true,"helloWorldWizardButtonLabel":"Get started with the Hello World Wizard","showDeploymentWizardButton":true,"deploymentWizardButtonLabel":"Deployment Wizard"},"drillDownPages":{}},{"id":"8557a68a-1f55-4553-a2f3-620613be7284","name":"Number of blueprints","width":2,"height":8,"x":2,"y":0,"definition":"blueprintNum","configuration":{"pollingTime":10,"page":"local_blueprints"},"drillDownPages":{}},{"id":"c1a2deb4-88de-4e1b-99ad-d3da0f6fe89c","name":"Number of deployments","width":2,"height":8,"x":4,"y":0,"definition":"deploymentNum","configuration":{"pollingTime":10,"page":"deployments"},"drillDownPages":{}},{"id":"02a88707-d138-4beb-9d1d-cae19dc358bd","name":"Number of plugins","width":2,"height":8,"x":6,"y":0,"definition":"pluginsNum","configuration":{"pollingTime":30,"page":"system_resources"},"drillDownPages":{}},{"id":"91c850ff-59ba-4676-894c-65ac2c2ca75d","name":"Number of compute nodes","width":2,"height":8,"x":8,"y":0,"definition":"nodesComputeNum","configuration":{"pollingTime":30},"drillDownPages":{}},{"id":"967f571c-3823-4450-9a5c-33cceea0c6e1","name":"Number of running executions","width":2,"height":8,"x":10,"y":0,"definition":"executionNum","configuration":{"pollingTime":10},"drillDownPages":{}},{"id":"c81ec31e-1e90-4be8-9395-4c1394d1ca12","name":"Blueprint Upload Button","width":2,"height":3,"x":2,"y":8,"definition":"blueprintUploadButton","configuration":{},"drillDownPages":{}},{"id":"5b378ce6-5a18-4ed6-ac60-7023fd231396","name":"Deployment Button","width":2,"height":3,"x":4,"y":8,"definition":"deploymentButton","configuration":{},"drillDownPages":{}},{"id":"5804992b-3106-45fa-9d46-93b31f0ecb54","name":"Plugin Upload Button","width":2,"height":3,"x":6,"y":8,"definition":"pluginUploadButton","configuration":{},"drillDownPages":{}},{"id":"96c141ef-2a33-48d5-8949-3941716b6143","name":"Filter","width":12,"height":3,"x":0,"y":10,"definition":"filter","configuration":{"pollingTime":10,"filterByBlueprints":true,"filterByDeployments":true,"filterByExecutions":false,"filterByNodes":false,"filterByNodeInstances":false,"allowMultipleSelection":false},"drillDownPages":{}},{"id":"be104e49-660d-4483-8f50-311dce65aca5","name":"Executions","width":12,"height":29,"x":0,"y":12,"definition":"executions","configuration":{"pollingTime":5,"pageSize":10,"fieldsToShow":["Blueprint","Deployment","Workflow","Created","Ended","Creator","Attributes","Actions","Status"],"showSystemExecutions":true,"sortColumn":"created_at","sortAscending":null},"drillDownPages":{}}]},{"id":"cloudify_catalog","name":"Cloudify Catalog","description":"","widgets":[{"id":"b3a0c46a-d948-42a1-8a63-26703528fc65","name":"Blueprints Catalog","width":12,"height":26,"x":0,"y":0,"definition":"blueprintCatalog","configuration":{"pageSize":3,"jsonPath":"//s3-eu-west-1.amazonaws.com/cloudify-labs/catalogs/catalog.json","username":"cloudify-examples","filter":"blueprint in:name NOT local","displayStyle":"catalog","sortColumn":"created_at","sortAscending":null},"drillDownPages":{}},{"id":"99e455c0-0803-453b-aa53-f40c4d4b56bd","name":"Plugins Catalog","width":12,"height":24,"x":0,"y":0,"definition":"pluginsCatalog","configuration":{"jsonPath":"//repository.cloudifysource.org/cloudify/wagons/plugins.json"},"drillDownPages":{}},{"id":"b006865b-9156-4b94-8dcc-37cc88e5e61c","name":"Composer link","width":2,"height":5,"x":0,"y":25,"definition":"composerLink","configuration":{},"drillDownPages":{}}]},{"id":"local_blueprints","name":"Local Blueprints","description":"","widgets":[{"id":"845467e1-ea08-4af5-8327-d8ce8aeb8ac6","name":"Blueprints","width":12,"height":24,"x":0,"y":0,"definition":"blueprints","configuration":{"pollingTime":10,"pageSize":5,"clickToDrillDown":true,"displayStyle":"table","sortColumn":"created_at","sortAscending":null},"drillDownPages":{}},{"id":"a41e2f4b-98f8-4afe-beca-e5e774705c27","name":"Composer link","width":2,"height":5,"x":0,"y":25,"definition":"composerLink","configuration":{},"drillDownPages":{}}]},{"id":"deployments","name":"Deployments","description":"","widgets":[{"id":"b9e1acd7-80ed-4b25-bf00-d8818402ce54","name":"Deployment Button","width":3,"height":3,"x":0,"y":0,"definition":"deploymentButton","configuration":{},"drillDownPages":{}},{"id":"db88a27d-8950-441b-b5db-b8a443235ffe","name":"Filter","width":12,"height":3,"x":0,"y":3,"definition":"filter","configuration":{"pollingTime":10,"filterByBlueprints":true,"filterByDeployments":false,"filterByExecutions":false,"filterByNodes":false,"filterByNodeInstances":false,"allowMultipleSelection":false},"drillDownPages":{}},{"id":"dc2cf2b4-9c4f-49a1-859e-58893a0fdafa","name":"Deployments","width":12,"height":40,"x":0,"y":7,"definition":"deployments","configuration":{"pollingTime":10,"pageSize":5,"clickToDrillDown":true,"showExecutionStatusLabel":false,"blueprintIdFilter":null,"displayStyle":"list","sortColumn":"created_at","sortAscending":null},"drillDownPages":{}}]},{"id":"tenant_management","name":"Tenant Management","description":"","widgets":[{"id":"e90fe880-feda-413d-b279-fd4dc45fa181","name":"User Management","width":12,"height":20,"definition":"userManagement","configuration":{"pollingTime":30,"pageSize":5,"sortColumn":"username","sortAscending":true},"drillDownPages":{}},{"id":"74e42ac7-e4d9-40ca-b21c-7410a273f4bb","name":"Tenants Management","width":12,"height":20,"definition":"tenants","configuration":{"pollingTime":30,"pageSize":5,"sortColumn":"name","sortAscending":true},"drillDownPages":{}},{"id":"593de249-2d38-4930-be28-df500a86121e","name":"User Groups Management","width":12,"height":20,"definition":"userGroups","configuration":{"pollingTime":30,"pageSize":5,"sortColumn":"name","sortAscending":true},"drillDownPages":{}}]},{"id":"admin_operations","name":"Admin Operations","description":"","widgets":[{"id":"497fd4f9-d403-4685-9bab-717e23949f6c","name":"Maintenance Mode Button","width":3,"height":3,"x":0,"y":0,"definition":"maintenanceModeButton","configuration":{},"drillDownPages":{}},{"id":"939946a3-91fc-4ad0-8166-36a2b7db3e23","name":"Cluster management","width":12,"height":24,"x":0,"y":3,"definition":"highAvailability","configuration":{"pollingTime":30,"pageSize":5,"sortColumn":"name","sortAscending":true},"drillDownPages":{}},{"id":"8c505d41-7ecb-4a9d-96bb-ac887ea48bdb","name":"Snapshots","width":12,"height":24,"x":0,"y":27,"definition":"snapshots","configuration":{"pollingTime":30,"pageSize":5,"sortColumn":"created_at","sortAscending":null},"drillDownPages":{}}]},{"id":"system_resources","name":"System Resources","description":"","widgets":[{"id":"0afd8115-ce1b-41c5-8a77-1f0c5f04a7a1","name":"Plugins","width":12,"height":24,"x":0,"y":0,"definition":"plugins","configuration":{"pollingTime":30,"pageSize":5},"drillDownPages":{}},{"id":"61dde189-b1e1-4ebf-b893-ad4ac0fe787a","name":"Secret Store Management","width":12,"height":24,"x":0,"y":24,"definition":"secrets","configuration":{"pollingTime":30,"pageSize":5,"sortColumn":"key","sortAscending":true},"drillDownPages":{}},{"id":"ec53565b-2e89-4bae-93f2-ee2284e42105","name":"Agents Management","width":12,"height":24,"x":0,"y":48,"definition":"agents","configuration":{"pollingTime":15,"fieldsToShow":["Id","Node","Deployment","IP","Install Method","System","Version","Actions"],"installMethods":[""]},"drillDownPages":{}}]},{"id":"statistics","name":"Statistics","description":"","widgets":[{"id":"dd74099f-ab67-459b-8d2d-08db0fd53ef8","name":"Nodes filter","width":8,"height":3,"x":0,"y":0,"definition":"filter","configuration":{"pollingTime":10,"filterByBlueprints":true,"filterByDeployments":true,"filterByExecutions":false,"filterByNodes":true,"filterByNodeInstances":true,"allowMultipleSelection":false},"drillDownPages":{}},{"id":"447fac63-e9dd-48f5-97c2-8730e5d1a466","name":"Time filter","width":4,"height":3,"x":8,"y":0,"definition":"timeFilter","configuration":{},"drillDownPages":{}},{"id":"1429be88-05df-436b-b194-bb8a82078f9e","name":"CPU Total User Graph","width":6,"height":17,"x":6,"y":7,"definition":"graph","configuration":{"pollingTime":5,"nodeFilter":{"blueprintId":"","deploymentId":"","nodeId":"","nodeInstanceId":""},"charts":{"0":{"metric":"cpu_total_user","label":"CPU Total User [%]"}},"query":null,"type":"line","timeFilter":{"range":"Last 15 Minutes","start":"now()-15m","end":"now()","resolution":1,"unit":"m"}},"drillDownPages":{}},{"id":"f40a453b-37f9-4c0d-89ec-45b2ce9ccc03","name":"Memory Free Graph","width":6,"height":17,"x":0,"y":7,"definition":"graph","configuration":{"pollingTime":5,"nodeFilter":{"blueprintId":"","deploymentId":"","nodeId":"","nodeInstanceId":""},"charts":{"0":{"metric":"memory_MemFree","label":"Memory [B]"}},"query":null,"type":"line","timeFilter":{"range":"Last 15 Minutes","start":"now()-15m","end":"now()","resolution":1,"unit":"m"}},"drillDownPages":{}},{"id":"6a29dd5f-6e8a-4533-a9af-5f154e356fb0","name":"CPU Total System Graph","width":6,"height":17,"x":0,"y":25,"definition":"graph","configuration":{"pollingTime":5,"nodeFilter":{"blueprintId":"","deploymentId":"","nodeId":"","nodeInstanceId":""},"charts":{"0":{"metric":"cpu_total_system","label":"CPU Total System [%]"}},"query":null,"type":"bar","timeFilter":{"range":"Last 15 Minutes","start":"now()-15m","end":"now()","resolution":1,"unit":"m"}},"drillDownPages":{}},{"id":"08af1b30-e33f-4005-9c3c-2e974e3b36d0","name":"Load Average Graph","width":6,"height":17,"x":6,"y":25,"definition":"graph","configuration":{"pollingTime":5,"nodeFilter":{"blueprintId":"","deploymentId":"","nodeId":"","nodeInstanceId":""},"charts":{"0":{"metric":"loadavg_processes_running","label":"Running Load Average [%]"}},"query":null,"type":"line","timeFilter":{"range":"Last 15 Minutes","start":"now()-15m","end":"now()","resolution":1,"unit":"m"}},"drillDownPages":{}}]},{"id":"logs","name":"Logs","description":"","widgets":[{"id":"1991ae39-02a9-4556-abf0-fd5edca8f7ac","name":"Resource Filter","width":12,"height":3,"x":0,"y":0,"definition":"filter","configuration":{"pollingTime":10,"filterByBlueprints":true,"filterByDeployments":true,"filterByExecutions":true,"filterByNodes":true,"filterByNodeInstances":true,"allowMultipleSelection":true},"drillDownPages":{}},{"id":"6045c99c-6733-4f1e-af5e-6afcad6f2948","name":"Events/logs filter widget","width":12,"height":5,"x":0,"y":5,"definition":"eventsFilter","configuration":{},"drillDownPages":{}},{"id":"ed76f432-55cd-4b1e-9d51-de3bb1b23e73","name":"Events and logs","width":12,"height":40,"x":0,"y":10,"definition":"events","configuration":{"pollingTime":2,"pageSize":15,"sortColumn":"timestamp","sortAscending":null,"fieldsToShow":["Icon","Timestamp","Blueprint","Deployment","Workflow","Operation","Node Id","Node Instance Id","Message"],"colorLogs":true,"maxMessageLength":200},"drillDownPages":{}}]}]}	2019-05-21 06:35:14.061+00	2019-05-21 06:35:14.082+00	default_tenant
\.


--
-- Name: UserApps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cloudify
--

SELECT pg_catalog.setval('"UserApps_id_seq"', 1, true);


--
-- Name: UserApps_pkey; Type: CONSTRAINT; Schema: public; Owner: cloudify
--

ALTER TABLE ONLY "UserApps"
    ADD CONSTRAINT "UserApps_pkey" PRIMARY KEY (id);


--
-- Name: user_apps_manager_ip_username_mode_tenant; Type: INDEX; Schema: public; Owner: cloudify
--

CREATE UNIQUE INDEX user_apps_manager_ip_username_mode_tenant ON "UserApps" USING btree ("managerIp", username, mode, tenant);


--
-- PostgreSQL database dump complete
--
