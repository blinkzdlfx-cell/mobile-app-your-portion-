-- Add id_type and face_image_url to verification_requests
ALTER TABLE verification_requests
ADD COLUMN id_type TEXT CHECK (id_type IN ('nin', 'voter_card', 'international_passport')),
ADD COLUMN face_image_url TEXT;

-- Allow admins to read all verification documents (already exists in 00004)
