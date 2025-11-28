-- database/customer_events.sql

CREATE TABLE IF NOT EXISTS customer_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    client_name TEXT NOT NULL,
    client_phone TEXT,
    event_type TEXT NOT NULL,
    event_date DATE NOT NULL,
    notes TEXT,
    last_purchase_reference UUID, -- Assuming this could link to an 'orders' table.
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS Policies for customer_events
ALTER TABLE customer_events ENABLE ROW LEVEL SECURITY;

-- Policy: Users can see their own customer events.
CREATE POLICY "Allow read access on own customer events"
ON customer_events
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert events for themselves.
CREATE POLICY "Allow insert on own customer events"
ON customer_events
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own events.
CREATE POLICY "Allow update on own customer events"
ON customer_events
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own events.
CREATE POLICY "Allow delete on own customer events"
ON customer_events
FOR DELETE
USING (auth.uid() = user_id);

-- Function to update the updated_at column automatically
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update 'updated_at' on row modification
CREATE TRIGGER on_customer_events_update
BEFORE UPDATE ON customer_events
FOR EACH ROW
EXECUTE PROCEDURE handle_updated_at();

-- Add comments to explain the table and columns
COMMENT ON TABLE customer_events IS 'Stores customer-related events and special dates for floristry tracking.';
COMMENT ON COLUMN customer_events.user_id IS 'The user ID of the florist owner who created the event.';
COMMENT ON COLUMN customer_events.client_name IS 'The name of the florist''s client.';
COMMENT ON COLUMN customer_events.client_phone IS 'The contact phone number for the client.';
COMMENT ON COLUMN customer_events.event_type IS 'The type of event (e.g., "cumpleaños", "aniversario", "navidad").';
COMMENT ON COLUMN customer_events.event_date IS 'The specific date of the event.';
COMMENT ON COLUMN customer_events.notes IS 'Optional notes or details about the event or client preferences.';
COMMENT ON COLUMN customer_events.last_purchase_reference IS 'Reference to the last purchase made by the client, possibly an order ID.';
