# Short List Module Documentation

## Overview

The Short List module is an inventory management feature designed to help merchants identify items that need restocking. It uses event-driven triggers to automatically flag items based on the **50% Rule** and slow item detection (30+ days without sales).

## Features

### 1. **50% Rule Auto-Detection**
- **Trigger**: When an item's current quantity drops below 50% of its last restock quantity
- **Example**: If an item was last restocked at 100 units and now has 45 units, it will be automatically added to the short list
- **Event-Driven**: Triggered immediately on any sale or quantity adjustment
- **No Cron Jobs**: Uses real-time hooks instead of background jobs for instant updates

### 2. **Slow Item Detection**
- **Trigger**: Items that haven't been sold in 30+ days
- **Indicator**: Tagged with "🐢 Slow Item" badge
- **Use Case**: Identify potential dead stock or items with low demand

### 3. **Manual Management**
- Add/remove items manually from the short list
- Override automatic detection when needed
- Track who added items manually

### 4. **PDF Export**
Generate three types of reports:
- **Short List PDF**: Current short list items with restock recommendations
- **Inventory PDF**: Full inventory with short list indicators
- **Analytics PDF**: Summary statistics and breakdown by reason

### 5. **Smart Sorting & Filtering**
- **Sort By**:
  - Lowest Stock First (default)
  - Recently Added
  - Item Name
- **Filter**:
  - All Items
  - Slow Items Only
  - 50% Rule Items Only

## Database Schema

### ShortList Table
```sql
CREATE TABLE short_list (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  inventory_id UUID NOT NULL UNIQUE REFERENCES inventory_items(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  is_slow_item BOOLEAN DEFAULT FALSE,
  reason VARCHAR(50), -- '50% rule', 'manual', 'slow_item'
  added_by VARCHAR(255), -- User ID or 'system'
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_tenant_id (tenant_id),
  INDEX idx_is_slow_item (is_slow_item),
  INDEX idx_added_at (added_at)
);
```

### InventoryItem Enhancements
```sql
ALTER TABLE inventory_items ADD COLUMN
  last_restock_qty INT, -- Last quantity restocked
  last_restock_date TIMESTAMP, -- Date of last restock
  last_moved_date TIMESTAMP; -- Last date item was sold
```

## API Endpoints

### Get All Short List Items
```
GET /api/v1/shortlist
?skip=0&take=100&sortBy=quantity&sortOrder=asc&filterSlow=false
```

**Response**:
```json
{
  "data": [
    {
      "id": "uuid",
      "inventoryId": "uuid",
      "isSlowItem": false,
      "reason": "50% rule",
      "addedAt": "2024-01-31T12:00:00Z",
      "inventory": {
        "id": "uuid",
        "itemName": "Paracetamol 500mg",
        "quantity": 45,
        "lastRestockQty": 100,
        "retailPrice": 10.50,
        "variant": { "sku": "SKU-001" }
      }
    }
  ],
  "total": 45,
  "skip": 0,
  "take": 100
}
```

### Get Short List Statistics
```
GET /api/v1/shortlist/stats
```

**Response**:
```json
{
  "total": 45,
  "slowItems": 12,
  "manualItems": 5,
  "autoRuleItems": 28,
  "totalQuantity": 1250
}
```

### Get Single Item
```
GET /api/v1/shortlist/:inventoryId
```

### Toggle Item (Add/Remove)
```
POST /api/v1/shortlist/toggle/:inventoryId
```

### Add Item (Manual)
```
POST /api/v1/shortlist/add/:inventoryId
```

### Remove Item
```
DELETE /api/v1/shortlist/:inventoryId
```

### Batch Add Items
```
POST /api/v1/shortlist/batch-add
Body: { "inventoryIds": ["id1", "id2", "id3"] }
```

## PDF Export Endpoints

### Export Short List PDF
```
GET /api/v1/export/pdf/shortlist
```

### Export Inventory PDF
```
GET /api/v1/export/pdf/inventory
```

### Export Analytics PDF
```
GET /api/v1/export/pdf/analytics
```

## Frontend Components

### ShortListPage
**Location**: `/src/app/dashboard/shortlist/page.tsx`

Main short list management interface with:
- Statistics dashboard
- Search and filter controls
- Sorting options
- PDF export buttons
- Item management table

### ShortListAddButton
**Location**: `/src/components/shortlist/ShortListAddButton.tsx`

Reusable button component for adding/removing items from short list.

**Usage**:
```tsx
<ShortListAddButton
  inventoryId="item-id"
  isInShortList={false}
  onSuccess={() => console.log('Updated')}
/>
```

### GlobalSearchWithShortList
**Location**: `/src/components/shortlist/GlobalSearchWithShortList.tsx`

Global search component with "Add to Short List" functionality.

**Usage**:
```tsx
<GlobalSearchWithShortList />
```

## Backend Services

### ShortListService
**Location**: `/src/modules/shortlist/shortlist.service.ts`

Core business logic:
- `autoCheckAndAdd()`: Automatically add item if meets 50% rule
- `toggle()`: Add/remove item manually
- `findAll()`: Get all short list items with filtering/sorting
- `markAsSlow()`: Mark item as slow
- `updateLastMoved()`: Update when item is sold
- `updateRestock()`: Update restock tracking

### PdfExportService
**Location**: `/src/modules/pdf-export/pdf-export.service.ts`

PDF generation using jsPDF and autoTable:
- `generateShortListPdf()`: Short list report
- `generateInventoryPdf()`: Inventory report with short list indicators
- `generateAnalyticsPdf()`: Summary analytics

## Integration Points

### Sales Service
When a sale is created, the short list service is triggered:

```typescript
// Update lastMovedDate
await this.shortListService.updateLastMoved(item.inventoryId);

// Check if item meets 50% rule
await this.shortListService.autoCheckAndAdd(item.inventoryId, tenantId);
```

### Inventory Service
When inventory is adjusted (restocked), update tracking fields:

```typescript
await this.shortListService.updateRestock(inventoryId, newQuantity);
```

## User Interface Flow

### Accessing Short List
1. Dashboard → **Short List** (new menu item)
2. View all items flagged for restocking
3. Sort by quantity, added date, or name
4. Filter by slow items or 50% rule
5. Export to PDF for physical records

### Adding Items from Inventory
1. Go to Inventory page
2. Click **Add to Short List** button on any item
3. Item immediately appears in Short List

### Adding Items via Global Search
1. Use global search bar: "Search items to add to short list"
2. Type item name or SKU
3. Click **+ Add** button
4. Item added to short list

### Exporting Reports
1. Go to Short List page
2. Click export button:
   - 📄 **Export Short List**: Current short list items
   - 📄 **Export Inventory**: Full inventory with indicators
   - 📊 **Export Analytics**: Summary statistics
3. PDF downloaded to device

## Configuration

### 50% Rule Threshold
Currently set to 50%. To change:

**File**: `/src/modules/shortlist/shortlist.service.ts`

```typescript
private async checkFiftyPercentRule(inventoryId: string): Promise<boolean> {
  const threshold = item.lastRestockQty / 2; // Change divisor here
  return item.quantity < threshold;
}
```

### Slow Item Duration
Currently set to 30 days. To change:

```typescript
private async checkSlowItem(inventoryId: string): Promise<boolean> {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000); // Change here
  return item.lastMovedDate < thirtyDaysAgo;
}
```

## Performance Optimization

### Indexing
Short list queries are optimized with indexes on:
- `tenant_id`: Fast tenant filtering
- `is_slow_item`: Fast slow item filtering
- `added_at`: Fast chronological sorting

### Pagination
API supports pagination with `skip` and `take` parameters:
```
GET /api/v1/shortlist?skip=0&take=50
```

### Lazy Loading
Frontend uses React Query for efficient caching and background updates:
```typescript
const { data, isLoading } = useQuery({
  queryKey: ['shortlist', sortBy],
  // ...
});
```

## Troubleshooting

### Items not appearing in short list
1. Check if `lastRestockQty` is set for the item
2. Verify item quantity is actually below 50% of `lastRestockQty`
3. Check `lastMovedDate` for slow item detection

### PDF export failing
1. Verify jsPDF dependencies are installed
2. Check browser console for errors
3. Ensure user has permission to export

### Performance issues
1. Check pagination parameters
2. Use filters to reduce result set
3. Consider archiving old slow items

## Future Enhancements

- [ ] Auto-generate purchase orders from short list
- [ ] Set custom thresholds per item or category
- [ ] Email notifications when items meet criteria
- [ ] Batch actions (select multiple, bulk export)
- [ ] Integration with supplier management
- [ ] Historical tracking of short list changes
- [ ] Predictive inventory using sales trends
- [ ] Automatic reorder suggestions with supplier info

## Support

For issues or feature requests, contact the development team or create an issue in the project repository.
