<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use App\Models\Product;
use App\Models\SaleItem;
use Illuminate\Http\Request;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        $today = Carbon::today();
        $thisMonth = Carbon::now()->startOfMonth();
        
        // Today's statistics
        $todaySales = Sale::whereDate('created_at', $today)
            ->where('status', 'completed')
            ->sum('total');
            
        $todayTransactions = Sale::whereDate('created_at', $today)
            ->where('status', 'completed')
            ->count();
        
        // This month's statistics
        $monthSales = Sale::where('created_at', '>=', $thisMonth)
            ->where('status', 'completed')
            ->sum('total');
            
        $monthTransactions = Sale::where('created_at', '>=', $thisMonth)
            ->where('status', 'completed')
            ->count();
        
        // Product statistics
        $totalProducts = Product::where('is_active', true)->count();
        $lowStockProducts = Product::where('is_active', true)
            ->where('stock_quantity', '<=', 10)
            ->count();
        
        // Top selling products this month
        $topProducts = SaleItem::join('products', 'sale_items.product_id', '=', 'products.id')
            ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->where('sales.created_at', '>=', $thisMonth)
            ->where('sales.status', 'completed')
            ->select('products.name', 'products.id')
            ->selectRaw('SUM(sale_items.quantity) as total_sold')
            ->groupBy('products.id', 'products.name')
            ->orderBy('total_sold', 'desc')
            ->limit(5)
            ->get();
        
        return response()->json([
            'today' => [
                'sales' => $todaySales,
                'transactions' => $todayTransactions,
            ],
            'month' => [
                'sales' => $monthSales,
                'transactions' => $monthTransactions,
            ],
            'products' => [
                'total' => $totalProducts,
                'low_stock' => $lowStockProducts,
            ],
            'top_products' => $topProducts,
        ]);
    }

    public function salesReport(Request $request)
    {
        $request->validate([
            'start_date' => 'date',
            'end_date' => 'date|after_or_equal:start_date',
            'period' => 'in:today,week,month,year',
        ]);

        $query = Sale::where('status', 'completed');

        if ($request->has('start_date') && $request->has('end_date')) {
            $query->whereBetween('created_at', [$request->start_date, $request->end_date]);
        } elseif ($request->has('period')) {
            switch ($request->period) {
                case 'today':
                    $query->whereDate('created_at', Carbon::today());
                    break;
                case 'week':
                    $query->where('created_at', '>=', Carbon::now()->startOfWeek());
                    break;
                case 'month':
                    $query->where('created_at', '>=', Carbon::now()->startOfMonth());
                    break;
                case 'year':
                    $query->where('created_at', '>=', Carbon::now()->startOfYear());
                    break;
            }
        }

        $sales = $query->with(['items.product', 'cashier'])->get();
        $totalSales = $sales->sum('total');
        $totalTransactions = $sales->count();

        return response()->json([
            'sales' => $sales,
            'summary' => [
                'total_sales' => $totalSales,
                'total_transactions' => $totalTransactions,
                'average_sale' => $totalTransactions > 0 ? $totalSales / $totalTransactions : 0,
            ],
        ]);
    }
}
