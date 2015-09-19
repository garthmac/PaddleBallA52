//
//  IAPHelper.swift
//  PaddleBallA52
//
//  Created by iMac 27 on 2015-09-16.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//


import UIKit
import StoreKit

class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{

    // Set IAPS
    func setIAPs() {
        if(SKPaymentQueue.canMakePayments()) {
            if list.isEmpty {
                print("IAP is enabled, loading")
                let productIDs = NSSet(objects: "com.garthmackenzie.PaddleBallA52.addCredits.10", "com.garthmackenzie.PaddleBallA52.addCredits.40", "com.garthmackenzie.PaddleBallA52.addCredits.70", "com.garthmackenzie.PaddleBallA52.addCredits.150", "com.garthmackenzie.PaddleBallA52.addCredits.350", "com.garthmackenzie.PaddleBallA52.addCredits.1000", "com.garthmackenzie.PaddleBallA52.addCredits.2500")
                let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDs as! Set<String>)
                request.delegate = self
                request.start()
            }
        } else {
            print("please enable IAPS")
        }
    }
    @IBAction func btnRemoveAds(sender: UIButton) {
        for product in list {
            let prodID = product.productIdentifier
            if(prodID == "com.garthmackenzie.PaddleBallA52.removeads") {
                p = product
                buyProduct()
                break;
            }
        }
    }
    @IBAction func btnRestorePurchases(sender: UIButton) {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    func pay4Credits(credits: Int) {
        for product in list {
            if product.productIdentifier.hasSuffix("\(credits)") {
                p = product
                buyProduct()
            }
        }
    }
    func addCredits(credits:Int) {
        Settings().availableCredits += credits
    }
    var list = [SKProduct]()
    var p = SKProduct()

    func buyProduct() {
        print("buy " + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    //MARK: - SKProductsRequestDelegate
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("product request")
        print("product count \(response.products.count)")
        print("invalid product IDs \(response.invalidProductIdentifiers)")
        let myProduct = response.products
        for product in myProduct {
            print("product added for $\(product.price)")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            list.append(product )
        }
    }
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("please enable IAPS")
        print(error.localizedDescription)
    }
    func removeAds() {
        //lblAdvert.removeFromSuperview()   //no ads to remove
    }
    //MARK: - SKPaymentTransactionObserver
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("transactions restored")
        for transaction in queue.transactions {
            let prodID = transaction.payment.productIdentifier
            switch prodID {
            case "com.garthmackenzie.PaddleBallA52.removeads":
                print("remove ads")
                removeAds()
            case "com.garthmackenzie.PaddleBallA52.addCredits.10":
                print("add 10 credits to account")
                addCredits(10)
            case "com.garthmackenzie.PaddleBallA52.addCredits.40":
                print("add 40 credits to account")
                addCredits(40)
            case "com.garthmackenzie.PaddleBallA52.addCredits.70":
                print("add 70 credits to account")
                addCredits(70)
            case "com.garthmackenzie.PaddleBallA52.addCredits.150":
                print("add 150 credits to account")
                addCredits(150)
            case "com.garthmackenzie.PaddleBallA52.addCredits.350":
                print("add 350 credits to account")
                addCredits(350)
            case "com.garthmackenzie.PaddleBallA52.addCredits.1000":
                print("add 1000 credits to account")
                addCredits(1000)
            case "com.garthmackenzie.PaddleBallA52.addCredits.2500":
                print("add 2500 credits to account")
                addCredits(2500)            default:
                print("IAP not setup")
            }
        }
    }
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add paymnet")
        for transaction in transactions {
            print(transaction.error)
            switch transaction.transactionState {
            case .Purchased:
                print("buy, ok unlock iap here")
                print(p.productIdentifier)
                let prodID = p.productIdentifier as String
                switch prodID {
                case "com.garthmackenzie.PaddleBallA52.removeads":
                    print("remove ads")
                    removeAds()
                case "com.garthmackenzie.PaddleBallA52.addCredits.10":
                    print("add 10 credits to account")
                    addCredits(10)
                case "com.garthmackenzie.PaddleBallA52.addCredits.40":
                    print("add 40 credits to account")
                    addCredits(40)
                case "com.garthmackenzie.PaddleBallA52.addCredits.70":
                    print("add 70 credits to account")
                    addCredits(70)
                case "com.garthmackenzie.PaddleBallA52.addCredits.150":
                    print("add 150 credits to account")
                    addCredits(150)
                case "com.garthmackenzie.PaddleBallA52.addCredits.350":
                    print("add 350 credits to account")
                    addCredits(350)
                case "com.garthmackenzie.PaddleBallA52.addCredits.1000":
                    print("add 1000 credits to account")
                    addCredits(1000)
                case "com.garthmackenzie.PaddleBallA52.addCredits.2500":
                    print("add 2500 credits to account")
                    addCredits(2500)
                default:
                        print("IAP not setup")
                }
                queue.finishTransaction(transaction)
                break;
            case .Failed:
                print("buy error")
                queue.finishTransaction(transaction)
                break;
            default:
                print("default")
                break;
            }
        }
    }
    func finishTransaction(trans:SKPaymentTransaction) {
        print("finish transaction")
        SKPaymentQueue.defaultQueue().finishTransaction(trans)
    }
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("remove transaction");
    }
}

