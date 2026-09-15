-- The org secret the artifact's Config.toml carries, so the runtime connects without a trip
-- through the UI. Skip this file to rehearse the real onboarding: copy the secret from the console.
-- The admin user is created on first login; no need to seed it.
INSERT INTO org_secrets (key_id, environment_id, key_material, created_by)
VALUES ('dev-workflow-lab', '750e8400-e29b-41d4-a716-446655440001',
        'dev-secret-that-is-at-least-32-bytes-long', NULL);

-- The task roles the workflow gates on. A human task is visible only to a caller whose token
-- carries a role of that NAME, and the seeded admin holds only Super Admin / Project Admin — so
-- without these grants Human Tasks is correctly empty, which reads like a bug and is not one.
-- Granting both to Super Admins lets one admin play manager and accountant.
INSERT INTO roles_v2 (role_id, role_name, org_id, description)
VALUES (RANDOM_UUID(), 'MANAGER', 1, 'Workflow lab task role'),
       (RANDOM_UUID(), 'ACCOUNTANT', 1, 'Workflow lab task role');

INSERT INTO group_role_mapping (group_id, role_id, org_uuid)
SELECT g.group_id, r.role_id, 1
  FROM user_groups g, roles_v2 r
 WHERE g.group_name = 'Super Admins'
   AND r.role_name IN ('MANAGER', 'ACCOUNTANT');
