# Memory Cache Implementation Plan

## Objective
To implement an aggressive caching strategy ("Memory Cache") for static assets to improve load performance, while ensuring immediate updates for dynamic content and the application shell (HTML).

## Strategy

### 1. Frontend (`supershop-frontend`)
**Technology:** Next.js deployed on Vercel.

**Approach:**
We utilize `vercel.json` to control HTTP headers at the edge/deployment level.

*   **Static Assets (Images, CSS, JS, Fonts):**
    *   **Target:** `/(.*).(jpg|jpeg|png|gif|svg|ico|css|js|woff|woff2)`
    *   **Header:** `Cache-Control: public, max-age=31536000, immutable`
    *   **Reasoning:** These files are typically hashed (e.g., `main.a1b2.js`) or static. "Immutable" tells the browser the file will never change, allowing it to serve directly from memory/disk cache without revalidation.

*   **Dynamic Content (HTML/Root):**
    *   **Target:** `/` (and other pages)
    *   **Header:** `Cache-Control: no-cache, no-store, must-revalidate`
    *   **Reasoning:** The HTML file contains references to the hashed assets. We must ensure the browser always fetches the latest HTML to discover if asset hashes have changed.

**Status:**
- [x] Updated `vercel.json` with header rules.

### 2. Backend (`supershop-backend`)
**Technology:** NestJS.

**Approach:**
We use `@nestjs/serve-static` to serve uploaded content (e.g., product images) directly from the backend's file system (specifically the `img` directory).

*   **Static File Serving:**
    *   **Module:** `ServeStaticModule`
    *   **Path:** `/img` (mapped to local `../img` folder)
    *   **Header Configuration:**
        ```typescript
        serveStaticOptions: {
          setHeaders: (res, path, stat) => {
            res.set('Cache-Control', 'public, max-age=31536000, immutable');
          },
        }
        ```
    *   **Reasoning:** Similar to frontend assets, product images should be cached aggressively. Cache busting for these images should be handled by client-side logic (e.g., appending a version query string or changing the filename) if the image content changes.

**Status:**
- [x] Installed `@nestjs/serve-static`.
- [x] Configured `AppModule` to serve `/img` with cache headers.
- [ ] Verify build and deployment.

## Verification
1.  **Frontend:** Inspect Network tab in DevTools. Reload page. Static assets should show "Memory Cache" or "Disk Cache" in the Size column. Response headers should show `max-age=31536000`.
2.  **Backend:** Request an image (e.g., `http://localhost:8080/img/logo.png`). Response headers should include `Cache-Control: public, max-age=31536000, immutable`.
