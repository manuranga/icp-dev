-- BI secret: pre-seeded so the bare lab's BI can connect immediately. For more realisic tests, don't seed, instead get the secret from the ui.
-- The admin user is auto-created on first login; no need to seed it.
INSERT INTO org_secrets (key_id, environment_id, key_material, created_by)
VALUES ('dev-very-bare-bi', '750e8400-e29b-41d4-a716-446655440001',
        'dev-secret-that-is-at-least-32-bytes-long', NULL);
