import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMonths;
  final String type; // 'Basic', 'Standard', 'Premium'
  final bool isActive;
  final String discount;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMonths,
    required this.type,
    required this.isActive,
    required this.discount,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationMonths: json['duration_months'] ?? 1,
      type: json['type'] ?? 'Basic',
      isActive: json['is_active'] ?? true,
      discount: json['discount'] ?? 'None',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration_months': durationMonths,
      'type': type,
      'is_active': isActive,
      'discount': discount,
    };
  }
}

class SubscriptionsPlansPage extends StatefulWidget {
  const SubscriptionsPlansPage({super.key});

  @override
  State<SubscriptionsPlansPage> createState() => _SubscriptionsPlansPageState();
}

class _SubscriptionsPlansPageState extends State<SubscriptionsPlansPage> {
  final supabase = Supabase.instance.client;
  List<SubscriptionPlan> plans = [];
  bool isLoading = true;
  bool showInactivePlans = false;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('subscription_plans')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        plans = (response as List)
            .map((json) => SubscriptionPlan.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading plans: $e')));
      }
    }
  }

  // New method to get filtered plans
  List<SubscriptionPlan> get filteredPlans {
    if (showInactivePlans) {
      return plans;
    }
    return plans.where((plan) => plan.isActive).toList();
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'premium':
        return Colors.purple;
      case 'standard':
        return Colors.blue;
      case 'basic':
        return Colors.indigo;
      default:
        return Colors.black;
    }
  }

  IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'premium':
        return Icons.diamond;
      case 'standard':
        return Icons.star;
      case 'basic':
        return Icons.fitness_center;
      default:
        return Icons.card_membership;
    }
  }

  void showAddEditDialog({SubscriptionPlan? plan}) {
    final nameController = TextEditingController(text: plan?.name ?? '');
    final descController = TextEditingController(text: plan?.description ?? '');
    final priceController = TextEditingController(
      text: plan?.price.toString() ?? '',
    );
    final durationController = TextEditingController(
      text: plan?.durationMonths.toString() ?? '',
    );
    final discountController = TextEditingController(
      text: plan?.discount ?? 'None',
    );
    String selectedType = plan?.type ?? 'Basic';
    bool isActive = plan?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(plan == null ? 'Add New Plan' : 'Edit Plan'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Plan Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: nameController,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Description (three lines max)',
                      border: OutlineInputBorder(),
                    ),
                    controller: descController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    controller: priceController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Duration (Months)',
                      border: OutlineInputBorder(),
                    ),
                    controller: durationController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Plan Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Basic', 'Standard', 'Premium']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedType = value!);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Discount (e.g., 10 or None)',
                      border: OutlineInputBorder(),
                    ),
                    controller: discountController,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Plan Status:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            setDialogState(() => isActive = value);
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final planData = {
                  'name': nameController.text,
                  'description': descController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'duration_months': int.tryParse(durationController.text) ?? 1,
                  'type': selectedType,
                  'discount': discountController.text,
                  'is_active': isActive,
                };

                try {
                  if (plan == null) {
                    await supabase.from('subscription_plans').insert(planData);
                  } else {
                    await supabase
                        .from('subscription_plans')
                        .update(planData)
                        .eq('id', plan.id);
                  }

                  Navigator.pop(context);
                  fetchPlans();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          plan == null
                              ? 'Plan added successfully'
                              : 'Plan updated successfully',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: Text(plan == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans & Bundles'),
        actions: [
          IconButton(
            icon: Icon(
              showInactivePlans ? Icons.visibility_off : Icons.visibility,
            ),
            tooltip: showInactivePlans
                ? 'Hide Inactive Plans'
                : 'Show Inactive Plans',
            onPressed: () {
              setState(() {
                showInactivePlans = !showInactivePlans;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: fetchPlans,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Stats Section - Only Plans Card
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _buildStatCard(
                'Total Plans',
                filteredPlans.length.toString(),
                Icons.card_membership,
                Colors.blue,
              ),
            ),

            // View Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPlans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            showInactivePlans
                                ? 'No plans available'
                                : 'No active plans available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            showInactivePlans
                                ? 'Click the button below to add your first plan'
                                : 'Toggle the visibility icon to show inactive plans',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildGridView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEditDialog(),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('Add Plan'),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
        child: Row(
          children: [
            SizedBox(width: 30),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 35),
            ),
            Spacer(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth >= 800) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 500) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth < 500) {
          crossAxisCount = 1;
        }

        final double horizontalPadding = 16 * 2;
        final double spacing = 18 * (crossAxisCount - 1);
        final double availableWidth =
            constraints.maxWidth - horizontalPadding - spacing;
        final double cardWidth = availableWidth / crossAxisCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Wrap(
            spacing: 18,
            runSpacing: 18,
            children: filteredPlans.map((plan) {
              return SizedBox(width: cardWidth, child: _buildPlanCard(plan));
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    // Precompute discount values so we don't declare variables inside the widget tree
    final bool hasDiscount =
        plan.discount != 'None' &&
        double.tryParse(plan.discount) != null &&
        double.parse(plan.discount) > 0;
    final double discountPercent = hasDiscount
        ? double.parse(plan.discount)
        : 0;
    final double discountedPrice = hasDiscount
        ? plan.price - (plan.price * discountPercent / 100)
        : plan.price;

    return Card(
      elevation: 5,
      shadowColor: getTypeColor(plan.type).withOpacity(0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [getTypeColor(plan.type).withOpacity(0.1), Colors.white],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              decoration: BoxDecoration(
                color: getTypeColor(plan.type),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Icon(getTypeIcon(plan.type), color: Colors.white, size: 25),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      plan.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!plan.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Inactive',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    plan.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 13),

                  // Discount info (computed above)
                  if (hasDiscount)
                    Container(
                      margin: const EdgeInsets.only(bottom: 13),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "${plan.discount}% OFF",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (hasDiscount) ...[
                        // Old price with strikethrough
                        Text(
                          '${plan.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // New/Current price
                      Text(
                        '${discountedPrice.toStringAsFixed(0)}\$',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: hasDiscount
                              ? Colors.green.shade700
                              : getTypeColor(plan.type),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '/${plan.durationMonths} month${plan.durationMonths > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showAddEditDialog(plan: plan),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: getTypeColor(plan.type),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: getTypeColor(plan.type)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 6),
                          Text('Edit', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Plan'),
                            content: Text(
                              'Are you sure you want to delete "${plan.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await supabase
                                        .from('subscription_plans')
                                        .delete()
                                        .eq('id', plan.id);
                                    Navigator.pop(context);
                                    fetchPlans();
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Plan deleted successfully',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(11),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
