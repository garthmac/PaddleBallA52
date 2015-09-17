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
            println("IAP is enabled, loading")
            var productIDs = NSSet(objects: "com.garthmackenzie.PaddleBallA52.addCredits.10", "com.garthmackenzie.PaddleBallA52.addCredits.40", "com.garthmackenzie.PaddleBallA52.addCredits.70", "com.garthmackenzie.PaddleBallA52.addCredits.150", "com.garthmackenzie.PaddleBallA52.addCredits.350", "com.garthmackenzie.PaddleBallA52.addCredits.1000", "com.garthmackenzie.PaddleBallA52.addCredits.2500")
            var request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDs as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            println("please enable IAPS")
        }
    }
    @IBAction func btnRemoveAds(sender: UIButton) {
        for product in list {
            var prodID = product.productIdentifier
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
            var prodID = product.productIdentifier
            if (prodID.lastPathComponent == "\(credits)") {
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
        println("buy " + p.productIdentifier)
        var pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    //MARK: - SKProductsRequestDelegate
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        println("product request")
        var myProduct = response.products
        for product in myProduct {
            println("product added")
            println(product.productIdentifier)
            println(product.localizedTitle)
            println(product.localizedDescription)
            println(product.price)
            list.append(product as! SKProduct)
        }
    }
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        println("please enable IAPS")
        println(error.localizedDescription)
    }
    func removeAds() {
        //lblAdvert.removeFromSuperview()   //no ads to remove
    }
    //MARK: - SKPaymentTransactionObserver
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        println("transactions restored")
        var purchasedItemIDS = []
        for transaction in queue.transactions {
            var t = transaction as! SKPaymentTransaction
            let prodID = t.payment.productIdentifier as String
            switch prodID {
            case "com.garthmackenzie.PaddleBallA52.removeads":
                println("remove ads")
                removeAds()
            case "com.garthmackenzie.PaddleBallA52.addCredits.10":
                println("add 10 credits to account")
                addCredits(10)
            case "com.garthmackenzie.PaddleBallA52.addCredits.40":
                println("add 40 credits to account")
                addCredits(40)
            case "com.garthmackenzie.PaddleBallA52.addCredits.70":
                println("add 70 credits to account")
                addCredits(70)
            case "com.garthmackenzie.PaddleBallA52.addCredits.150":
                println("add 150 credits to account")
                addCredits(150)
            case "com.garthmackenzie.PaddleBallA52.addCredits.350":
                println("add 350 credits to account")
                addCredits(350)
            case "com.garthmackenzie.PaddleBallA52.addCredits.1000":
                println("add 1000 credits to account")
                addCredits(1000)
            case "com.garthmackenzie.PaddleBallA52.addCredits.2500":
                println("add 2500 credits to account")
                addCredits(2500)            default:
                println("IAP not setup")
            }
        }
    }
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("add paymnet")
        for transaction:AnyObject in transactions {
            var trans = transaction as! SKPaymentTransaction
            println(trans.error)
            switch trans.transactionState {
            case .Purchased:
                println("buy, ok unlock iap here")
                println(p.productIdentifier)
                let prodID = p.productIdentifier as String
                switch prodID {
                case "com.garthmackenzie.PaddleBallA52.removeads":
                    println("remove ads")
                    removeAds()
                case "com.garthmackenzie.PaddleBallA52.addCredits.10":
                    println("add 10 credits to account")
                    addCredits(10)
                case "com.garthmackenzie.PaddleBallA52.addCredits.40":
                    println("add 40 credits to account")
                    addCredits(40)
                case "com.garthmackenzie.PaddleBallA52.addCredits.70":
                    println("add 70 credits to account")
                    addCredits(70)
                case "com.garthmackenzie.PaddleBallA52.addCredits.150":
                    println("add 150 credits to account")
                    addCredits(150)
                case "com.garthmackenzie.PaddleBallA52.addCredits.350":
                    println("add 350 credits to account")
                    addCredits(350)
                case "com.garthmackenzie.PaddleBallA52.addCredits.1000":
                    println("add 1000 credits to account")
                    addCredits(1000)
                case "com.garthmackenzie.PaddleBallA52.addCredits.2500":
                    println("add 2500 credits to account")
                    addCredits(2500)
                default:
                        println("IAP not setup")
                }
                queue.finishTransaction(trans)
                break;
            case .Failed:
                println("buy error")
                queue.finishTransaction(trans)
                break;
            default:
                println("default")
                break;
            }
        }
    }
    func finishTransaction(trans:SKPaymentTransaction) {
        println("finish trans")
        SKPaymentQueue.defaultQueue().finishTransaction(trans)
    }
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
        println("remove trans");
    }
}

