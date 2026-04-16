INSERT INTO org_secrets (key_id, environment_id, key_material, created_by)
VALUES ('dev-very-bare-bi', '750e8400-e29b-41d4-a716-446655440001',
        'dev-secret-that-is-at-least-32-bytes-long', NULL);

INSERT INTO users (user_id, username, display_name, is_super_admin, is_project_author, is_oidc_user, require_password_change)
VALUES ('550e8400-e29b-41d4-a716-446655440000', 'admin', 'Admin', TRUE, TRUE, FALSE, FALSE);

INSERT INTO group_user_mapping (group_id, user_uuid)
VALUES ('e34608f1-d2f6-4975-8212-682e2a4bdd0f', '550e8400-e29b-41d4-a716-446655440000');
