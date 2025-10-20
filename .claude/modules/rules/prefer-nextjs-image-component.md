---
id: rule-032
type: rule
version: 1.0.0
description: Use Next.js Image component instead of HTML img tags for automatic optimization, performance benefits, and modern web standards
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Prefer Next.js Image Component Rule (rule-032)

## Purpose
The Next.js Image component provides automatic image optimization, performance benefits, and modern web standards that regular HTML `<img>` tags cannot match. Using `<img>` tags directly bypasses critical optimizations that can significantly impact Core Web Vitals, SEO rankings, and user experience.

Regular `<img>` tags lead to poor performance with no automatic optimization, layout shifts causing poor CLS scores, missed optimization opportunities like lazy loading and responsive sizing, larger bundle sizes without automatic WebP/AVIF conversion, and poor mobile experience without responsive image generation.

## Requirements

### MUST (Critical)
- **NEVER use** HTML `<img>` tags in Next.js applications
- **ALWAYS use** the `Image` component from `next/image` for all images
- **IMPORT properly** using `import Image from 'next/image'`
- **CONFIGURE required props** (`src`, `alt`, and size information)
- **USE `priority`** for above-the-fold images that impact LCP
- **CONFIGURE `remotePatterns`** in `next.config.js` for external images

### SHOULD (Important)
- **PROVIDE descriptive alt text** for accessibility
- **USE `sizes` prop** for responsive images
- **IMPLEMENT proper placeholder strategies** (blur, empty, etc.)
- **OPTIMIZE image loading** with appropriate quality settings
- **FOLLOW responsive design principles** with proper container sizing

### MAY (Optional)
- **USE advanced placeholder options** for better UX
- **IMPLEMENT blurDataURL** for custom blur placeholders
- **CONFIGURE quality settings** per image use case
- **USE fill prop** with object-fit for complex layouts
- **IMPLEMENT error boundaries** for image loading failures

## Forbidden Patterns

### ❌ ALL HTML IMG TAGS ARE FORBIDDEN
```tsx
// ❌ FORBIDDEN - Basic img tag
<img
  src="/hero.jpg"
  alt="Hero image"
  width="800"
  height="600"
/>

// ❌ FORBIDDEN - External image
<img
  src="https://example.com/photo.jpg"
  alt="External photo"
  style={{ width: '100%' }}
/>

// ❌ FORBIDDEN - Dynamic image
<img
  src={user.avatar}
  alt="User avatar"
  className="w-12 h-12 rounded-full"
/>

// ❌ FORBIDDEN - Background image as img
<div className="bg-gray-100">
  <img src="/background.jpg" alt="Background" style={{ width: '100%' }} />
</div>

// ❌ FORBIDDEN - Lazy loading with img
<img
  src="/large-image.jpg"
  alt="Large image"
  loading="lazy"
  width="1200"
  height="800"
/>
```

## Correct Implementation Patterns

### Pattern 1: Basic Static Images
```tsx
// ✅ GOOD - Static image with proper props
import Image from 'next/image';
import heroImage from '/public/hero.jpg';

function HeroSection() {
  return (
    <div className="relative">
      <Image
        src={heroImage}
        alt="Hero section showing modern web application dashboard"
        width={1200}
        height={600}
        priority // Above-the-fold, loads immediately
        placeholder="blur" // Automatic blur placeholder
        className="rounded-lg"
      />
    </div>
  );
}
```

### Pattern 2: Remote External Images
```tsx
// ✅ GOOD - External image with proper configuration
import Image from 'next/image';

function UserProfile({ user }: { user: { avatar: string; name: string } }) {
  return (
    <div className="flex items-center space-x-4">
      <Image
        src={user.avatar}
        alt={`${user.name}'s profile picture`}
        width={64}
        height={64}
        className="rounded-full object-cover"
        sizes="(max-width: 768px) 64px, 64px"
        quality={85}
      />
      <div>
        <h3 className="font-semibold">{user.name}</h3>
        <p className="text-sm text-gray-600">User Profile</p>
      </div>
    </div>
  );
}
```

### Pattern 3: Responsive Images with Fill
```tsx
// ✅ GOOD - Responsive image with fill prop
import Image from 'next/image';

function ImageGallery() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {images.map((image, index) => (
        <div key={index} className="relative aspect-square">
          <Image
            src={image.url}
            alt={image.alt}
            fill
            sizes="(max-width: 768px) 100vw, (max-width: 1024px) 50vw, 33vw"
            className="object-cover rounded-lg"
            placeholder="blur"
            blurDataURL={image.blurDataURL}
          />
        </div>
      ))}
    </div>
  );
}
```

### Pattern 4: Avatar and Profile Images
```tsx
// ✅ GOOD - User avatars with error handling
import Image from 'next/image';

function UserAvatar({
  user,
  size = 40,
  className = ""
}: {
  user: { name: string; avatar?: string };
  size?: number;
  className?: string;
}) {
  return (
    <div
      className={`relative ${className}`}
      style={{ width: size, height: size }}
    >
      <Image
        src={user.avatar || '/default-avatar.png'}
        alt={`${user.name}'s avatar`}
        fill
        sizes={`${size}px`}
        className="rounded-full object-cover"
        onError={(e) => {
          // Fallback to default avatar on error
          const target = e.target as HTMLImageElement;
          target.src = '/default-avatar.png';
        }}
      />
    </div>
  );
}
```

### Pattern 5: Product Images for E-commerce
```tsx
// ✅ GOOD - E-commerce product images
import Image from 'next/image';

function ProductCard({ product }: { product: Product }) {
  return (
    <div className="border rounded-lg overflow-hidden">
      <div className="relative aspect-square">
        <Image
          src={product.imageUrl}
          alt={`${product.name} - ${product.description}`}
          fill
          sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
          className="object-cover"
          placeholder="blur"
          blurDataURL={product.blurDataUrl}
          priority={product.featured}
        />
        {product.discount > 0 && (
          <div className="absolute top-2 right-2 bg-red-500 text-white px-2 py-1 rounded text-sm">
            -{product.discount}%
          </div>
        )}
      </div>
      <div className="p-4">
        <h3 className="font-semibold">{product.name}</h3>
        <p className="text-gray-600">${product.price}</p>
      </div>
    </div>
  );
}
```

## Advanced Configuration

### Next.js Configuration for External Images
```javascript
// ✅ GOOD - next.config.js with proper image configuration
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'example.com',
        port: '',
        pathname: '/images/**',
      },
      {
        protocol: 'https',
        hostname: 'cdn.example.com',
        port: '',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
        port: '',
        pathname: '/**',
      },
    ],
    formats: ['image/webp', 'image/avif'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384, 512],
  },
};

module.exports = nextConfig;
```

### Custom Image Component Wrapper
```tsx
// ✅ GOOD - Custom wrapper for consistent image handling
import Image, { ImageProps } from 'next/image';
import { cn } from '@/lib/utils';

interface OptimizedImageProps extends Omit<ImageProps, 'placeholder'> {
  fallbackSrc?: string;
  wrapperClassName?: string;
}

export function OptimizedImage({
  src,
  alt,
  fallbackSrc,
  className,
  wrapperClassName,
  placeholder = 'blur',
  ...props
}: OptimizedImageProps) {
  const [error, setError] = useState(false);

  return (
    <div className={cn('relative', wrapperClassName)}>
      <Image
        src={error && fallbackSrc ? fallbackSrc : src}
        alt={alt}
        className={cn('transition-opacity', className)}
        placeholder={placeholder}
        onError={() => setError(true)}
        {...props}
      />
      {error && !fallbackSrc && (
        <div className="absolute inset-0 flex items-center justify-center bg-gray-200 text-gray-500">
          <span className="text-2xl">🖼️</span>
        </div>
      )}
    </div>
  );
}
```

## Performance Optimization Patterns

### Priority Loading for Critical Images
```tsx
// ✅ GOOD - Strategic priority loading
function ArticlePage({ article }: { article: Article }) {
  return (
    <article>
      {/* Hero image - highest priority */}
      <OptimizedImage
        src={article.heroImage}
        alt={article.title}
        width={1200}
        height={600}
        priority={true}
        quality={90}
        placeholder="blur"
        className="w-full rounded-lg mb-8"
      />

      {/* Content images - normal loading */}
      <div className="prose max-w-none">
        {article.content.blocks.map((block, index) => (
          <div key={index} className="my-6">
            {block.type === 'image' && (
              <OptimizedImage
                src={block.data.url}
                alt={block.data.alt}
                width={800}
                height={400}
                quality={75}
                placeholder="empty"
                className="w-full rounded-lg"
              />
            )}
          </div>
        ))}
      </div>

      {/* Author avatar - lower priority */}
      <div className="flex items-center mt-8 pt-8 border-t">
        <OptimizedImage
          src={article.author.avatar}
          alt={`${article.author.name}'s avatar`}
          width={48}
          height={48}
          quality={80}
          className="rounded-full mr-4"
        />
        <div>
          <p className="font-semibold">{article.author.name}</p>
          <p className="text-sm text-gray-600">Published {article.publishedAt}</p>
        </div>
      </div>
    </article>
  );
}
```

### Responsive Image Strategies
```tsx
// ✅ GOOD - Responsive image with art direction
function ResponsiveHeroSection() {
  return (
    <div className="relative">
      {/* Desktop image */}
      <div className="hidden lg:block">
        <Image
          src="/hero-desktop.jpg"
          alt="Hero section showing application dashboard on desktop"
          width={1920}
          height={1080}
          priority={true}
          placeholder="blur"
          className="w-full"
        />
      </div>

      {/* Tablet image */}
      <div className="hidden md:block lg:hidden">
        <Image
          src="/hero-tablet.jpg"
          alt="Hero section showing application dashboard on tablet"
          width={1024}
          height={768}
          priority={true}
          placeholder="blur"
          className="w-full"
        />
      </div>

      {/* Mobile image */}
      <div className="md:hidden">
        <Image
          src="/hero-mobile.jpg"
          alt="Hero section showing application dashboard on mobile"
          width={640}
          height={480}
          priority={true}
          placeholder="blur"
          className="w-full"
        />
      </div>
    </div>
  );
}
```

## Loading States and UX Patterns

### Blur Placeholder Strategy
```tsx
// ✅ GOOD - Blur placeholders for better perceived performance
import Image from 'next/image';

function CardWithImage({ card }: { card: Card }) {
  const [isLoading, setIsLoading] = useState(true);

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <div className="relative aspect-video">
        <Image
          src={card.imageUrl}
          alt={card.title}
          fill
          sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
          className="object-cover"
          placeholder="blur"
          blurDataURL={card.blurDataUrl}
          onLoad={() => setIsLoading(false)}
        />
        {isLoading && (
          <div className="absolute inset-0 bg-gray-200 animate-pulse" />
        )}
      </div>
      <div className="p-4">
        <h3 className="font-semibold text-lg">{card.title}</h3>
        <p className="text-gray-600 mt-1">{card.description}</p>
      </div>
    </div>
  );
}
```

### Skeleton Loading Pattern
```tsx
// ✅ GOOD - Skeleton loading with Image component
function ProductGridSkeleton() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      {Array.from({ length: 6 }).map((_, index) => (
        <div key={index} className="bg-white rounded-lg overflow-hidden">
          <div className="relative aspect-video">
            <div className="absolute inset-0 bg-gray-200 animate-pulse" />
          </div>
          <div className="p-4">
            <div className="h-4 bg-gray-200 rounded animate-pulse mb-2" />
            <div className="h-3 bg-gray-200 rounded animate-pulse w-3/4" />
          </div>
        </div>
      ))}
    </div>
  );
}
```

## Accessibility Best Practices

### Alt Text Guidelines
```tsx
// ✅ GOOD - Descriptive alt text for content images
<Image
  src="/team-photo.jpg"
  alt="Team of five developers collaborating around a whiteboard with code snippets and diagrams"
  width={800}
  height={600}
/>

// ✅ GOOD - Empty alt for decorative images
<Image
  src="/decorative-pattern.svg"
  alt=""
  width={100}
  height={20}
  aria-hidden={true}
/>

// ✅ GOOD - Functional alt text for interactive images
<button type="button" className="relative">
  <Image
    src="/play-button.png"
    alt="Play video tutorial"
    width={48}
    height={48}
  />
  <span className="sr-only">Play video tutorial</span>
</button>

// ✅ GOOD - Alt text with context for user avatars
<Image
  src="/user-avatar.jpg"
  alt="Sarah Chen's profile picture"
  width={40}
  height={40}
/>
```

## Error Handling and Fallbacks

### Comprehensive Error Handling
```tsx
// ✅ GOOD - Robust error handling with fallbacks
import Image from 'next/image';
import { useState } from 'react';

interface SafeImageProps {
  src: string;
  alt: string;
  fallbackSrc?: string;
  className?: string;
  [key: string]: any;
}

export function SafeImage({
  src,
  alt,
  fallbackSrc = '/placeholder.jpg',
  className = '',
  ...props
}: SafeImageProps) {
  const [hasError, setHasError] = useState(false);
  const [imageSrc, setImageSrc] = useState(src);

  const handleError = () => {
    if (!hasError && fallbackSrc) {
      setHasError(true);
      setImageSrc(fallbackSrc);
    } else {
      setHasError(true);
    }
  };

  return (
    <Image
      src={imageSrc}
      alt={alt}
      className={cn(
        'transition-opacity duration-300',
        hasError ? 'opacity-50' : 'opacity-100',
        className
      )}
      onError={handleError}
      {...props}
    />
  );
}
```

## Migration Guide

### Converting Existing img Tags
```tsx
// ❌ BEFORE - HTML img tag
<img
  src="/hero-banner.jpg"
  alt="Hero banner"
  className="w-full h-96 object-cover"
  loading="lazy"
/>

// ✅ AFTER - Next.js Image component
import Image from 'next/image';

<Image
  src="/hero-banner.jpg"
  alt="Hero banner"
  fill
  sizes="100vw"
  className="object-cover"
  priority={true}
  style={{
    position: 'absolute',
    height: '100%',
    width: '100%'
  }}
/>
```

### Batch Migration Strategy
```bash
# 1. Find all img tags in the codebase
find src -name "*.tsx" -o -name "*.ts" | xargs grep -l "<img"

# 2. Convert them systematically
# Replace patterns like:
# <img src="/path/to/image.jpg" alt="..." width="800" height="600" />
# With:
# <Image src="/path/to/image.jpg" alt="..." width={800} height={600} />

# 3. Add Image imports where needed
# Add: import Image from 'next/image';
```

## Validation Checklist
- [ ] NO HTML `<img>` tags anywhere in the codebase
- [ ] All images use `Image` component from `next/image`
- [ ] Required props are provided: `src`, `alt`, and sizing information
- [ ] `priority` is used for above-the-fold images
- [ ] `sizes` prop is configured for responsive images
- [ ] `remotePatterns` configured in next.config.js for external images
- [ ] Descriptive alt text provided for all content images
- [ ] Empty alt text used for decorative images
- [ ] Proper error handling implemented for external images
- [] Placeholder strategies implemented for better UX
- [ ] Performance monitoring shows improved Core Web Vitals

## Enforcement
This rule is enforced through:
- ESLint rules to detect HTML img tags
- Code review validation
- Automated testing for image optimization
- Performance monitoring for Core Web Vitals
- Build-time validation for missing Next.js Image imports
- Accessibility testing for alt text compliance

By consistently using the Next.js Image component, we ensure optimal image performance, better Core Web Vitals scores, superior user experience, and maintainable image handling across the application.