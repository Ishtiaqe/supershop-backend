import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';

const PDF_FONT = {
  TITLE: 16,
  SECTION: 12,
  BODY: 10,
  FOOTER: 9,
};

@Injectable()
export class PdfExportService {
  constructor(private prisma: PrismaService) {}

  /**
   * Generate Short List PDF
   */
  async generateShortListPdf(tenantId: string): Promise<Buffer> {
    const items = await this.prisma.shortList.findMany({
      where: { tenantId },
      include: {
        inventory: {
          include: {
            variant: {
              include: {
                product: true,
              },
            },
          },
        },
      },
      orderBy: { inventory: { quantity: 'asc' } },
    });

    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.getWidth();
    const margin = 10;

    // Title
    doc.setFontSize(PDF_FONT.TITLE);
    doc.text('SHORT LIST REPORT', margin, margin + 5);

    // Date
    doc.setFontSize(PDF_FONT.BODY);
    const now = new Date();
    const day = String(now.getDate()).padStart(2, '0');
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const year = now.getFullYear();
    doc.text(`Generated on: ${day}/${month}/${year}`, margin, margin + 12);

    // Table data
    const tableData = items.map((item) => [
      item.inventory.itemName || item.inventory.variant?.product?.name || 'N/A',
      item.inventory.variant?.sku || 'N/A',
      item.inventory.quantity.toString(),
      item.inventory.lastRestockQty?.toString() || 'N/A',
      item.isSlowItem ? 'Yes' : 'No',
      item.reason,
      (() => {
        const d = new Date(item.addedAt);
        const day = String(d.getDate()).padStart(2, '0');
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const year = d.getFullYear();
        return `${day}/${month}/${year}`;
      })(),
    ]);

    // Generate table
    autoTable(doc, {
      head: [
        [
          'Item Name',
          'SKU',
          'Current Qty',
          'Last Restock Qty',
          'Slow Item',
          'Reason',
          'Added Date',
        ],
      ],
      body: tableData,
      startY: margin + 20,
      margin: { left: margin, right: margin },
      theme: 'grid',
      columnStyles: {
        0: { cellWidth: 40 },
        1: { cellWidth: 25 },
        2: { cellWidth: 20 },
        3: { cellWidth: 25 },
        4: { cellWidth: 20 },
        5: { cellWidth: 30 },
        6: { cellWidth: 30 },
      },
      didDrawPage: (data) => {
        // Footer
        const pageCount = doc.getNumberOfPages();
        const pageSize = doc.internal.pageSize;
        const pageHeight = pageSize.getHeight();
        const pageWidth = pageSize.getWidth();

        doc.setFontSize(PDF_FONT.FOOTER);
        doc.text(
          `Page ${data.pageNumber} of ${pageCount}`,
          pageWidth / 2,
          pageHeight - 10,
          { align: 'center' },
        );
      },
    });

    return Buffer.from(doc.output('arraybuffer'));
  }

  /**
   * Generate Inventory PDF with short list indicators
   */
  async generateInventoryPdf(tenantId: string): Promise<Buffer> {
    const inventoryItems = await this.prisma.inventoryItem.findMany({
      where: { tenantId },
      include: {
        variant: {
          include: {
            product: true,
          },
        },
      },
      orderBy: { quantity: 'asc' },
      take: 1000,
    });

    // Get short list item IDs for quick lookup
    const shortListIds = new Set(
      (
        await this.prisma.shortList.findMany({
          where: { tenantId },
          select: { inventoryId: true },
        })
      ).map((item) => item.inventoryId)
    );

    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.getWidth();
    const margin = 10;

    // Title
    doc.setFontSize(PDF_FONT.TITLE);
    doc.text('INVENTORY REPORT', margin, margin + 5);

    // Date
    doc.setFontSize(PDF_FONT.BODY);
    const now2 = new Date();
    const day2 = String(now2.getDate()).padStart(2, '0');
    const month2 = String(now2.getMonth() + 1).padStart(2, '0');
    const year2 = now2.getFullYear();
    doc.text(`Generated on: ${day2}/${month2}/${year2}`, margin, margin + 12);

    // Summary stats
    const lowStockCount = inventoryItems.filter(
      (item) =>
        item.lastRestockQty &&
        item.quantity < item.lastRestockQty / 2,
    ).length;
    doc.setFontSize(10);
    doc.text(`Total Items: ${inventoryItems.length}`, margin, margin + 20);
    doc.text(`Items in Short List: ${lowStockCount}`, margin, margin + 27);

    // Table data
    const tableData = inventoryItems.map((item) => [
      item.itemName || item.variant?.product?.name || 'N/A',
      item.variant?.sku || 'N/A',
      item.quantity.toString(),
      item.purchasePrice.toFixed(2),
      item.retailPrice.toFixed(2),
      shortListIds.has(item.id) ? 'YES' : 'NO',
      item.lastMovedDate
        ? (() => {
            const d = new Date(item.lastMovedDate);
            const day = String(d.getDate()).padStart(2, '0');
            const month = String(d.getMonth() + 1).padStart(2, '0');
            const year = d.getFullYear();
            return `${day}/${month}/${year}`;
          })()
        : 'Never',
    ]);

    // Generate table
    autoTable(doc, {
      head: [
        [
          'Item Name',
          'SKU',
          'Qty',
          'Cost Price',
          'Retail Price',
          'In Short List',
          'Last Moved',
        ],
      ],
      body: tableData,
      startY: margin + 35,
      margin: { left: margin, right: margin },
      theme: 'grid',
      columnStyles: {
        0: { cellWidth: 40 },
        1: { cellWidth: 25 },
        2: { cellWidth: 18 },
        3: { cellWidth: 25 },
        4: { cellWidth: 25 },
        5: { cellWidth: 25 },
        6: { cellWidth: 30 },
      },
      didDrawPage: (data) => {
        const pageCount = doc.getNumberOfPages();
        const pageSize = doc.internal.pageSize;
        const pageHeight = pageSize.getHeight();

        doc.setFontSize(PDF_FONT.FOOTER);
        doc.text(
          `Page ${data.pageNumber} of ${pageCount}`,
          pageWidth / 2,
          pageHeight - 10,
          { align: 'center' },
        );
      },
    });

    return Buffer.from(doc.output('arraybuffer'));
  }

  /**
   * Generate Analytics PDF
   */
  async generateAnalyticsPdf(tenantId: string): Promise<Buffer> {
    const shortListStats = await this.prisma.shortList.groupBy({
      by: ['reason'],
      where: { tenantId },
      _count: true,
    });

    const slowItemsCount = await this.prisma.shortList.count({
      where: { tenantId, isSlowItem: true },
    });

    const doc = new jsPDF();
    const margin = 10;

    // Title
    doc.setFontSize(PDF_FONT.TITLE);
    doc.text('SHORT LIST ANALYTICS', margin, margin + 5);

    // Date
    doc.setFontSize(PDF_FONT.BODY);
    const now3 = new Date();
    const day3 = String(now3.getDate()).padStart(2, '0');
    const month3 = String(now3.getMonth() + 1).padStart(2, '0');
    const year3 = now3.getFullYear();
    doc.text(`Generated on: ${day3}/${month3}/${year3}`, margin, margin + 12);

    // Statistics
    let yPos = margin + 25;
    doc.setFontSize(PDF_FONT.SECTION);

    doc.text('Summary Statistics:', margin, yPos);
    yPos += 10;

    doc.setFontSize(10);
    const totalShortList = await this.prisma.shortList.count({
      where: { tenantId },
    });
    doc.text(`Total Items in Short List: ${totalShortList}`, margin + 5, yPos);
    yPos += 7;

    doc.text(`Slow Items (30+ days): ${slowItemsCount}`, margin + 5, yPos);
    yPos += 7;

    // Breakdown by reason
    doc.text('Breakdown by Reason:', margin, yPos + 5);
    yPos += 12;

    shortListStats.forEach((stat) => {
      doc.text(`${stat.reason}: ${stat._count} items`, margin + 5, yPos);
      yPos += 7;
    });

    return Buffer.from(doc.output('arraybuffer'));
  }
}
