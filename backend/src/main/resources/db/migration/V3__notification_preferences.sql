create table notification_preferences (
    id uuid primary key,
    user_id uuid not null references app_users(id) on delete cascade,
    vehicle_id uuid not null references vehicles(id) on delete cascade,
    entity_type varchar(64) not null,
    entity_id uuid not null,
    enabled boolean not null default true,
    reminder_days_before jsonb not null default '[]'::jsonb,
    notify_on_due_date boolean not null default true,
    notification_time varchar(5) not null default '09:00',
    created_at timestamptz not null,
    updated_at timestamptz not null,
    constraint chk_notification_preferences_entity_type
        check (entity_type in ('LEGAL_DOCUMENT', 'MAINTENANCE')),
    constraint chk_notification_preferences_days_json
        check (jsonb_typeof(reminder_days_before) = 'array'),
    constraint chk_notification_preferences_time
        check (notification_time ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$')
);

create unique index idx_notification_preferences_user_entity
    on notification_preferences(user_id, entity_type, entity_id);

create index idx_notification_preferences_user_vehicle
    on notification_preferences(user_id, vehicle_id);
