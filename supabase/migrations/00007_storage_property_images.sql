-- Create storage bucket for property images (public — anyone can view approved properties' images)
INSERT INTO storage.buckets (id, name, public)
VALUES ('property_images', 'property_images', true)
ON CONFLICT (id) DO NOTHING;

-- Allow sellers to upload property images
CREATE POLICY "Sellers can upload property images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'property_images'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow anyone to view property images (properties are public)
CREATE POLICY "Anyone can view property images"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'property_images'
);

-- Allow sellers to update their own property images
CREATE POLICY "Sellers can update own property images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'property_images'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'property_images'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow sellers to delete their own property images
CREATE POLICY "Sellers can delete own property images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'property_images'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
