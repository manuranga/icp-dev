INSERT INTO org_secrets (key_id, environment_id, key_material, created_by)
VALUES
    ('tmp', '750e8400-e29b-41d4-a716-446655440001',
     'single-integration-use-dev-env-secret-for-local-use-only-do-not-use-in-production',
     (SELECT user_id FROM users LIMIT 1)),
    ('tmpmi', '750e8400-e29b-41d4-a716-446655440001',
     'mi-only-dev-env-secret-for-local-use-only-do-not-use-in-production-placeholder',
     (SELECT user_id FROM users LIMIT 1))
ON CONFLICT DO NOTHING;
