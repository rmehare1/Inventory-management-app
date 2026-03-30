/// Centralized Hive adapter registration and model exports.
///
/// Import this file to access all Hive models and register all adapters.
library;

import 'package:hive/hive.dart';

// Model exports
export 'package:inv_x/features/inventory/data/models/product_model.dart';
export 'package:inv_x/features/inventory/data/models/category_model.dart';
export 'package:inv_x/features/inventory/data/models/stock_movement_model.dart';
export 'package:inv_x/features/inventory/data/models/batch_model.dart';
export 'package:inv_x/features/suppliers/data/models/supplier_model.dart';
export 'package:inv_x/features/orders/data/models/purchase_order_model.dart';
export 'package:inv_x/features/orders/data/models/order_item_model.dart';
export 'package:inv_x/features/ai_chat/data/models/chat_message_model.dart';
export 'package:inv_x/core/ai/models/ai_call_log.dart';
export 'package:inv_x/features/ai_forecast/data/models/forecast_model.dart';
export 'package:inv_x/features/ai_anomaly/data/models/anomaly_model.dart';
export 'package:inv_x/data/hive/app_settings_model.dart';

// Model imports for adapter registration
import 'package:inv_x/features/inventory/data/models/product_model.dart';
import 'package:inv_x/features/inventory/data/models/category_model.dart';
import 'package:inv_x/features/inventory/data/models/stock_movement_model.dart';
import 'package:inv_x/features/inventory/data/models/batch_model.dart';
import 'package:inv_x/features/suppliers/data/models/supplier_model.dart';
import 'package:inv_x/features/orders/data/models/purchase_order_model.dart';
import 'package:inv_x/features/orders/data/models/order_item_model.dart';
import 'package:inv_x/features/ai_chat/data/models/chat_message_model.dart';
import 'package:inv_x/core/ai/models/ai_call_log.dart';
import 'package:inv_x/features/ai_forecast/data/models/forecast_model.dart';
import 'package:inv_x/features/ai_anomaly/data/models/anomaly_model.dart';
import 'package:inv_x/data/hive/app_settings_model.dart';

/// Registers all Hive TypeAdapters.
///
/// Must be called before opening any Hive boxes.
/// Each adapter is registered only if not already registered for its typeId.
void registerAllHiveAdapters() {
  // TypeId 0: ProductModel
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ProductModelAdapter());
  }

  // TypeId 1: CategoryModel
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }

  // TypeId 2: SupplierModel
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SupplierModelAdapter());
  }

  // TypeId 3: StockMovementModel
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(StockMovementModelAdapter());
  }

  // TypeId 4: PurchaseOrderModel
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(PurchaseOrderModelAdapter());
  }

  // TypeId 5: OrderItemModel
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(OrderItemModelAdapter());
  }

  // TypeId 6: ChatMessageModel
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(ChatMessageModelAdapter());
  }

  // TypeId 7: AiCallLog
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(AiCallLogAdapter());
  }

  // TypeId 8: ForecastModel
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(ForecastModelAdapter());
  }

  // TypeId 9: AnomalyModel
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(AnomalyModelAdapter());
  }

  // TypeId 10: AppSettingsModel
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(AppSettingsModelAdapter());
  }

  // TypeId 11: BatchModel
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(BatchModelAdapter());
  }
}
