/**
 * Service interface contracts for key domain services
 * Enables dependency inversion: services depend on interfaces, not implementations
 */

/**
 * ShortList service domain logic
 */
export interface IShortListService {
  /**
   * Update the last moved timestamp for an inventory item
   */
  updateLastMoved(inventoryId: string, tenantId: string): Promise<void>;

  /**
   * Auto-check and add item to short list if stock is low
   */
  autoCheckAndAdd(inventoryId: string, tenantId: string): Promise<void>;

  /**
   * Manually add item to short list
   */
  addItem(itemId: string, tenantId: string): Promise<void>;

  /**
   * Manually remove item from short list
   */
  removeItem(itemId: string, tenantId: string): Promise<void>;
}

/**
 * CashBox service domain logic
 */
export interface ICashBoxService {
  /**
   * Create a cash box entry
   */
  createEntry(
    tenantId: string,
    createdById: string,
    data: {
      entryType: string;
      amount: number;
      referenceId?: string;
      note?: string;
    }
  ): Promise<void>;

  /**
   * Get cash box balance for tenant
   */
  getBalance(tenantId: string): Promise<number>;
}

/**
 * Inventory service domain logic
 */
export interface IInventoryService {
  /**
   * Create inventory item
   */
  createItem(
    tenantId: string,
    data: {
      variantId?: string;
      itemName?: string;
      quantity: number;
      purchasePrice: number;
      retailPrice: number;
      batchNo?: string;
    }
  ): Promise<any>;

  /**
   * Update inventory quantity
   */
  updateQuantity(
    inventoryId: string,
    quantityChange: number
  ): Promise<void>;

  /**
   * Get inventory by ID
   */
  getById(inventoryId: string): Promise<any>;
}

/**
 * Catalog service domain logic
 */
export interface ICatalogService {
  /**
   * Get or create product
   */
  getOrCreateProduct(
    tenantId: string,
    name: string,
    categoryId?: string,
    brandId?: string
  ): Promise<any>;

  /**
   * Get or create variant
   */
  getOrCreateVariant(
    productId: string,
    variantName: string,
    sku: string
  ): Promise<any>;
}

/**
 * Sales domain events
 */
export interface ISalesService {
  /**
   * Create a sale transaction
   */
  createSale(
    tenantId: string,
    createdById: string,
    data: {
      items: Array<{
        inventoryId: string;
        quantity: number;
        discount?: number;
      }>;
      paymentMethod: string;
    }
  ): Promise<any>;
}
