/**
 * Base repository interface following Dependency Inversion Principle (DIP)
 * Services should depend on this interface, not concrete implementations
 */
export interface IBaseRepository<T, CreateDTO, UpdateDTO> {
  /**
   * Create a new entity
   */
  create(data: CreateDTO): Promise<T>;

  /**
   * Find entity by ID
   */
  findById(id: string): Promise<T | null>;

  /**
   * Find all entities for a tenant
   */
  findByTenant(tenantId: string): Promise<T[]>;

  /**
   * Update an entity
   */
  update(id: string, data: UpdateDTO): Promise<T>;

  /**
   * Delete an entity
   */
  delete(id: string): Promise<void>;

  /**
   * Count entities by criteria
   */
  count(where?: Record<string, any>): Promise<number>;
}

/**
 * Extended interface for paginated queries
 */
export interface IPaginatedRepository<T, CreateDTO, UpdateDTO>
  extends IBaseRepository<T, CreateDTO, UpdateDTO> {
  /**
   * Find with pagination
   */
  findPaginated(
    where: Record<string, any>,
    skip: number,
    take: number,
    orderBy?: Record<string, any>
  ): Promise<{items: T[]; total: number}>;
}

/**
 * Extended interface for searchable entities
 */
export interface ISearchableRepository<T, CreateDTO, UpdateDTO>
  extends IPaginatedRepository<T, CreateDTO, UpdateDTO> {
  /**
   * Search with query
   */
  search(
    tenantId: string,
    query: string,
    skip?: number,
    take?: number
  ): Promise<{items: T[]; total: number}>;
}
