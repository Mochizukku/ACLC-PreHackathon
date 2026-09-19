import '../models/menu_item.dart';

class SampleMenuData {
  static final List<String> categories = [
    'All',
    'Combos & Meals',
    'Burgers & Crispy',
    'Fried Chicken',
    'Sides & Snacks',
    'Drinks & Shakes',
  ];

  static final List<MenuItem> items = [
    MenuItem(
      id: 'm1',
      name: 'Signature Crispy Chicken Combo',
      description: 'Golden extra-crispy fried chicken leg & thigh served with seasoned rice, savory gravy, and an iced tea.',
      price: 189.00,
      category: 'Combos & Meals',
      imageUrl: 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?auto=format&fit=crop&w=600&q=80',
      isBestseller: true,
      prepareTimeMinutes: 6,
      customizationGroups: [
        CustomizationGroup(
          title: 'Piece Portion',
          isRequired: true,
          options: [
            CustomizationOption(id: 'c1', name: '1-pc Chicken Combo', price: 0.0),
            CustomizationOption(id: 'c2', name: '2-pc Chicken Combo (+₱65)', price: 65.0),
          ],
        ),
        CustomizationGroup(
          title: 'Drink Choice',
          isRequired: true,
          options: [
            CustomizationOption(id: 'd1', name: 'House Iced Tea (16oz)', price: 0.0),
            CustomizationOption(id: 'd2', name: 'Sparkling Lemonade (+₱20)', price: 20.0),
            CustomizationOption(id: 'd3', name: 'Creamy Mango Shake (+₱35)', price: 35.0),
          ],
        ),
        CustomizationGroup(
          title: 'Add-ons',
          allowMultiple: true,
          options: [
            CustomizationOption(id: 'a1', name: 'Extra Gravy Bowl', price: 15.0),
            CustomizationOption(id: 'a2', name: 'Extra Garlic Rice', price: 25.0),
            CustomizationOption(id: 'a3', name: 'Crispy Coleslaw', price: 35.0),
          ],
        ),
      ],
    ),
    MenuItem(
      id: 'm2',
      name: 'Double Smash Beef Burger',
      description: 'Two smashed grass-fed beef patties, melted cheddar cheese, caramelized onions, pickles & secret sauce.',
      price: 210.00,
      category: 'Burgers & Crispy',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
      isBestseller: true,
      prepareTimeMinutes: 7,
      customizationGroups: [
        CustomizationGroup(
          title: 'Fries & Drink Meal Upgrade',
          options: [
            CustomizationOption(id: 'u1', name: 'Solo Sandwich Only', price: 0.0),
            CustomizationOption(id: 'u2', name: 'Make it a Meal (Large Fries + Drink)', price: 75.0),
          ],
        ),
        CustomizationGroup(
          title: 'Extra Toppings',
          allowMultiple: true,
          options: [
            CustomizationOption(id: 't1', name: 'Extra Smoked Bacon Slice', price: 30.0),
            CustomizationOption(id: 't2', name: 'Extra Melted Cheddar', price: 20.0),
            CustomizationOption(id: 't3', name: 'Jalapeño Slices', price: 15.0),
          ],
        ),
      ],
    ),
    MenuItem(
      id: 'm3',
      name: 'Spicy Firebird Chicken Sandwich',
      description: 'Crispy habanero-dipped chicken breast filet, jalapeño slaw, and spicy garlic aioli on a toasted brioche bun.',
      price: 195.00,
      category: 'Burgers & Crispy',
      imageUrl: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?auto=format&fit=crop&w=600&q=80',
      isSpicy: true,
      isBestseller: true,
      prepareTimeMinutes: 8,
      customizationGroups: [
        CustomizationGroup(
          title: 'Spice Level',
          isRequired: true,
          options: [
            CustomizationOption(id: 's1', name: 'Mild Kick', price: 0.0),
            CustomizationOption(id: 's2', name: 'Hot Firebird', price: 0.0),
            CustomizationOption(id: 's3', name: 'Extremely Spicy (Insane)', price: 0.0),
          ],
        ),
      ],
    ),
    MenuItem(
      id: 'm4',
      name: '6-Piece Golden Tender Bucket',
      description: 'Hand-breathed boneless chicken tenders cooked to golden perfection with honey mustard & barbecue dip.',
      price: 299.00,
      category: 'Fried Chicken',
      imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=600&q=80',
      prepareTimeMinutes: 10,
      customizationGroups: [
        CustomizationGroup(
          title: 'Dipping Sauces (Choose 2)',
          allowMultiple: true,
          options: [
            CustomizationOption(id: 'dip1', name: 'Smokey BBQ Dip', price: 0.0),
            CustomizationOption(id: 'dip2', name: 'Honey Mustard Dip', price: 0.0),
            CustomizationOption(id: 'dip3', name: 'Spicy Garlic Ranch', price: 15.0),
          ],
        ),
      ],
    ),
    MenuItem(
      id: 'm5',
      name: 'Load-Up Potato Lattice Fries',
      description: 'Criss-cut lattice fries smothered in warm cheese sauce, crispy bacon bits, and spring onions.',
      price: 135.00,
      category: 'Sides & Snacks',
      imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=600&q=80',
      prepareTimeMinutes: 4,
    ),
    MenuItem(
      id: 'm6',
      name: 'Classic Creamy Spaghetti',
      description: 'Sweet savory meaty spaghetti sauce topped with abundant grated cheddar cheese and garlic toast slice.',
      price: 125.00,
      category: 'Combos & Meals',
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281270?auto=format&fit=crop&w=600&q=80',
      isBestseller: false,
      prepareTimeMinutes: 5,
    ),
    MenuItem(
      id: 'm7',
      name: 'Mango Peach Ice Cream Sundae',
      description: 'Rich vanilla soft-serve ice cream swirled with sweet mango peach glaze and graham crust dust.',
      price: 75.00,
      category: 'Sides & Snacks',
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80',
      prepareTimeMinutes: 3,
    ),
    MenuItem(
      id: 'm8',
      name: 'Zero Sugar Sparking Berry Chiller',
      description: 'Refreshing fizzy sparkling soda infused with wild berry puree and fresh mint leaves.',
      price: 85.00,
      category: 'Drinks & Shakes',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      prepareTimeMinutes: 3,
    ),
  ];
}
