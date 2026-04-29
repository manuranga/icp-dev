-- MI secret: pre-seeded so MI can connect immediately.
INSERT INTO org_secrets (key_id, environment_id, key_material, created_by)
VALUES ('tmpmi', '750e8400-e29b-41d4-a716-446655440001',
        'mi-artifacts-lab-secret-that-is-at-least-32-bytes-long', NULL);
