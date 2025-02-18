import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/functions.dart';
import '../../constants/style.dart';
import '../../custom_widgets/line_chart.dart';
import '../../custom_widgets/transactions_list.dart';
import '../../providers/accounts_provider.dart';
import '../../model/transaction.dart';
import '../../model/account.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountPage();
}

class _AccountPage extends ConsumerState<AccountPage> with Functions {
  /// Displays a confirmation message before deleting
  void _confirmDelete(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete this account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog.
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {

                ref
                    .read(accountsProvider.notifier)
                    .deleteAccount(account); 
                Navigator.of(context).pop(); // Close the dialog.
                // Optionally, navigate away from the account page.
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.read(selectedAccountProvider);
    final accountTransactions =
        ref.watch(selectedAccountCurrentMonthDailyBalanceProvider);
    final transactions = ref.watch(selectedAccountLastTransactions);

    return Scaffold(
      appBar: AppBar(
        title: Text(account?.name ?? "",
            style: const TextStyle(color: white)),
        backgroundColor: blue5,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (account != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Account',
              onPressed: () => _confirmDelete(context, account),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              color: blue5,
              child: Column(
                children: [
                  Text(
                    numToCurrency(account?.total),
                    style: const TextStyle(
                      color: white,
                      fontSize: 32.0,
                      fontFamily: 'SF Pro Text',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LineChartWidget(
                      lineData: accountTransactions,
                      colorBackground: blue5,
                      period: Period.month,
                      minY: 0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 40.0),
              child: TransactionsList(
                transactions: transactions
                    .map((json) => Transaction.fromJson(json))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
